# frozen_string_literal: true

# MODS from MARC service for retrieving and transforming MARC records
# Copied from https://github.com/sul-dlss/dor-services-app/blob/bc4e13495d72570cdb76808b2b48e4bf6cbface5/app/services/catalog/marc_service.rb
class ModsFromMarcService
  class MarcServiceError < RuntimeError; end
  class CatalogResponseError < MarcServiceError; end
  class CatalogRecordNotFoundError < MarcServiceError; end
  class TransformError < MarcServiceError; end

  # @param folio_instance_hrid [String] the FOLIO instance HRID
  # @return [String] MODS XML
  # @raise CatalogResponseError
  # @raise CatalogRecordNotFoundError
  # Usage:
  #   MarcService.mods(folio_instance_hrid: 'instance-123')
  def self.mods(folio_instance_hrid:)
    new(folio_instance_hrid:).mods
  end

  # @param folio_instance_hrid [String] the FOLIO instance HRID
  def initialize(folio_instance_hrid:)
    @folio_instance_hrid = folio_instance_hrid
  end

  # @return [String] MODS XML
  # @raise CatalogResponseError
  def mods
    @mods ||= mods_ng.to_xml
  end

  private

  attr_reader :folio_instance_hrid

  # @return [Nokogiri::XML::Document] MODS XML
  # @raise CatalogResponseError
  # @raise CatalogRecordNotFoundError
  def mods_ng
    @mods_ng ||= begin
      marc_to_mods_xslt.transform(marcxml_ng)
    rescue RuntimeError => e
      raise TransformError, "Error transforming MARC to MODS: #{e.message}"
    end
  end

  # @return [Nokogiri::XML::Document] MARCXML XML
  # @raise CatalogResponseError
  # @raise CatalogRecordNotFoundError
  def marcxml_ng
    @marcxml_ng ||= Nokogiri::XML(marc_record.to_xml.to_s)
  end

  # @return [MARC::Record] MARC record
  # @raise CatalogResponseError
  # @raise CatalogRecordNotFoundError
  def marc_record
    @marc_record ||= marc_record_from_folio
  end

  def marc_to_mods_xslt
    @marc_to_mods_xslt ||= Nokogiri::XSLT(File.open(Rails.root.join('app/xslt/MARC21slim2MODS3-7_SDR_v2-7.xsl')))
  end

  def marc_record_from_folio
    FolioReaderService.to_marc(folio_instance_hrid:)
  rescue FolioClient::ResourceNotFound
    raise CatalogRecordNotFoundError, "Catalog record not found. HRID: #{folio_instance_hrid} | Barcode: #{barcode}"
  rescue FolioClient::Error => e
    raise CatalogResponseError, "Error getting record from catalog: #{e.message}"
  end
end
