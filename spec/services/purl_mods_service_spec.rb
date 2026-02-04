# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PurlModsService do
  subject(:mods_service) { described_class.call(public_xml) }

  let(:public_xml) { Nokogiri::XML(File.read(File.join(FIXTURES_PATH, 'gh795jd5965.xml'))) }

  describe '.call' do
    it 'returns the MODS XML from the public XML' do
      expect(mods_service).to be_a(Nokogiri::XML::Element)
      expect(mods_service.name).to eq('mods')
    end
  end
end
