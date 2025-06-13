# frozen_string_literal: true

require 'rails_helper'

describe PurlModsService do
  subject(:mods_service) { described_class.call(public_xml) }

  let(:public_xml) { Nokogiri::XML(File.read(File.join(FIXTURES_PATH, 'gh795jd5965.xml'))) }

  describe '.call' do
    it 'returns the MODS XML from the public XML' do
      expect(mods_service).to be_a(Nokogiri::XML::Element)
      expect(mods_service.name).to eq('mods')
    end

    context 'when the MODS XML is not found in the public XML' do
      let(:public_xml) { Nokogiri::XML(File.read(File.join(FIXTURES_PATH, 'dx969tv9730.xml'))) }
      let(:mods_document) { File.read(File.join(FIXTURES_PATH, 'dx969tv9730.mods')) }
      let(:purl_service) { instance_double(PurlService) }

      before do
        allow(PurlService).to receive(:new).with('dx969tv9730', format: :mods).and_return(purl_service)
        allow(purl_service).to receive(:response_body).and_return(mods_document)
        allow(Honeybadger).to receive(:notify)
      end

      it 'fetches the MODS document from PURL' do
        expect(mods_service.elements.first).to be_a(Nokogiri::XML::Element)
        expect(mods_service.elements.first.name).to eq('mods')
      end

      it 'notifies Honeybadger about the fallback' do
        mods_service
        expect(Honeybadger).to have_received(:notify).with(
          'Unable to find MODS in the public xml; falling back to stand-alone mods document',
          context: { druid: 'dx969tv9730' }
        )
      end
    end
  end
end
