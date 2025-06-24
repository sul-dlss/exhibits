# frozen_string_literal: true

require 'rails_helper'

describe ModsService do
  subject(:mods_service) { described_class.call(purl_object:) }

  let(:purl_object) { Purl.new('druid:kj040zn0537') }

  before do
    %w(xml json).each do |format|
      stub_request(:get, "https://purl.stanford.edu/kj040zn0537.#{format}").to_return(
        body: File.new(File.join(FIXTURES_PATH, "kj040zn0537.#{format}")), status: 200
      )
    end
  end

  describe '.call' do
    it 'returns MODS XML' do
      expect(mods_service).to be_a(Nokogiri::XML::Element)
    end
  end

  describe '#mods_xml' do
    it 'returns MODS XML from PURL if no catalog record ID is present' do
      expect(mods_service).to be_a(Nokogiri::XML::Element)
      expect(mods_service.to_xml).to include('<title>Dauphin enlevè à sa mere</title>')
    end

    context 'when a catalog record ID is present' do
      let(:purl_object) { Purl.new('druid:vg729nb7574') }

      before do
        stub_request(:get, 'https://purl.stanford.edu/vg729nb7574.json').to_return(
          body: File.new(File.join(FIXTURES_PATH, 'vg729nb7574.json')), status: 200
        )
        allow(ModsFromMarcService).to receive(:mods).with(folio_instance_hrid: 'a365010').and_return(
          File.read(File.join(FIXTURES_PATH, 'a365010.mods'))
        )
      end

      it 'injects Cocina metadata into MODS XML from catalog record' do
        expect(mods_service).to be_a(Nokogiri::XML::Document)
        expect(mods_service.to_xml).to include('<partNumber>Fascicule 15, partie 1</partNumber>')
        expect(mods_service.to_xml).to include('<accessCondition type="useAndReproduction">')
        expect(mods_service.to_xml).to include('<accessCondition type="copyright">')
      end
    end
  end
end
