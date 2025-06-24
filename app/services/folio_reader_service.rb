# frozen_string_literal: true

# Reader from Folio's JSON API to fetch marc json given a HRID
# Copied from https://github.com/sul-dlss/dor-services-app/blob/7e6ad8802bd816faaef88678dfef09981f42a3df/app/services/catalog/folio_reader.rb
class FolioReaderService
  def self.to_marc(folio_instance_hrid:)
    new(folio_instance_hrid:).to_marc
  end

  attr_reader :folio_instance_hrid

  FIELDS_TO_REMOVE = %w(001 003).freeze

  # @param folio_instance_hrid [String] the FOLIO instance HRID
  def initialize(folio_instance_hrid:)
    @folio_instance_hrid = folio_instance_hrid
  end

  # @return [MARC::Record]
  # @raise FolioClient::UnexpectedResponse::ResourceNotFound, and
  # FolioClient::UnexpectedResponse::MultipleResourcesFound, and Catalog::FolioReader::NotFound
  def to_marc
    # fetch the record from folio
    marc = MARC::Record.new_from_hash(FolioClient.fetch_marc_hash(instance_hrid: folio_instance_hrid))
    # build up new mutated record
    updated_marc = MARC::Record.new
    updated_marc.leader = marc.leader
    marc.fields.each do |field|
      # explicitly remove all listed tags from the record
      updated_marc.fields << field unless FIELDS_TO_REMOVE.include? field.tag
    end
    # explicitly inject the instance_hrid into the 001 field
    updated_marc.fields << MARC::ControlField.new('001', folio_instance_hrid)
    # explicitly inject FOLIO into the 003 field
    updated_marc.fields << MARC::ControlField.new('003', 'FOLIO')
    updated_marc
  end
end
