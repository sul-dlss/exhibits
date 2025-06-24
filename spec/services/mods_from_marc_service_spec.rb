# frozen_string_literal: true

require 'rails_helper'

describe ModsFromMarcService do
  subject(:mods_from_marc) { described_class.mods(folio_instance_hrid:) }

  let(:folio_instance_hrid) { 'a1518292' }
  let(:folio_reader_service) { instance_double(FolioReaderService) }
  let(:marc_record) { MARC::XMLReader.new(File.join(FIXTURES_PATH, 'a1518292.xml'), parser: 'nokogiri').first }

  before do
    allow(FolioReaderService).to receive(:new).with(folio_instance_hrid:).and_return(folio_reader_service)
    allow(folio_reader_service).to receive(:to_marc).and_return(marc_record)
  end

  describe '.mods' do
    it 'returns MODS XML for a given FOLIO instance HRID' do
      expect(mods_from_marc).to be_a(String)
      expect(mods_from_marc).to include('<mods')
      expect(mods_from_marc).to include('<title>Bibliographie de Manon Lescaut</title>')
    end
  end
end
