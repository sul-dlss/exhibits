# frozen_string_literal: true

# Wrapper for working with an object from PURL
class Purl
  include ActiveSupport::Benchmarkable
  include ModsDisplay::RelatorCodes

  attr_reader :druid

  # @param druid [String] the PURL identifier (Druid), e.g. 'druid:abc123'
  # @example
  #   Purl.new('druid:abc123')
  def initialize(druid)
    @druid = druid
  end

  delegate :exists?, to: :purl_cocina_service
  delegate :virtual_object_thumbnail_identifier, :virtual_object?, to: :purl_virtual_object
  delegate :collection?, to: :cocina_record

  # @return [Nokogiri::XML::Document] the public XML document for this Purl object
  def public_xml
    @public_xml ||= Nokogiri::XML(PurlService.new(bare_druid, format: :xml).response_body)
  end

  # @return [Hash] the public cocina hash for this Purl object
  def public_cocina
    @public_cocina ||= cocina_record.cocina_doc
  end

  # @return [Array<Purl>] array of Purl objects for the collections this Purl belongs to
  def collections
    @collections ||= PurlCollections.call(public_cocina)
  end

  # @return [Array<String>] array of collection member druids for this Purl object
  def collection_member_druids
    @collection_member_druids ||= collection? ? PurlCollectionMemberDruids.call(druid) : []
  end

  # @return [String] the bare druid identifier without the 'druid:' prefix
  def bare_druid
    @bare_druid ||= druid.delete_prefix('druid:')
  end

  # @return [String] the catalog record ID from the active refresh catalog record, if available
  def active_folio_hrid
    cocina_record.folio_hrid(refresh: true)
  end

  # @return [CocinaDisplay::CocinaRecord] an object from the cocina-display gem that provides
  # methods for accessing Cocina metadata for indexing and display
  def cocina_record
    @cocina_record ||= CocinaDisplay::CocinaRecord.new(JSON.parse(cocina_service_response_body))
  end

  # @return [Stanford::Mods::Record] this object includes method for accessing MODS fields
  # in a more convenient way, see: https://github.com/sul-dlss/stanford-mods/
  def smods_rec
    @smods_rec ||= Stanford::Mods::Record.new.tap do |smods_rec|
      smods_rec.from_str(mods_xml.to_s)
    end
  end

  # NOTE: this is used only when indexing MODS in dor_mods_config.rb
  # @return [Array<Hash>] an array of hashes with keys `name` and `roles` with
  # MODS names normalized to just the display name and roles.
  def display_names_with_roles
    smods_rec.plain_name.map do |element|
      name = ModsDisplay::NameFormatter.format(element)

      roles = element.xpath('mods:role', mods: MODS_NS).map do |role|
        codes, text = role.xpath('mods:roleTerm', mods: MODS_NS).partition { |term| term['type'] == 'code' }

        # prefer mappable role term codes
        label = codes.map { |term| relator_codes[term.text.downcase] }.first

        # but fall back to given text
        label || text.map { |term| format_role(term) }.first
      end.uniq.compact_blank

      { name: name, roles: roles || [] }
    end
  end

  # @return [CocinaPhysicalLocation] an object that provides methods for accessing
  # physical location information from the Cocina record for indexing and display
  def cocina_physical_location
    @cocina_physical_location ||= CocinaPhysicalLocation.new(cocina_record:)
  end

  # @return [String] the last updated timestamp in ISO 8601 format
  def last_updated
    @last_updated ||= Time.zone.parse(public_cocina.fetch('modified', ''))&.utc&.iso8601
  end

  # @return [String] the thumbnail identifier for this PURL object
  def thumbnail_identifier
    return PurlThumbnail.call(purl_object: self) unless virtual_object?

    # If this PURL object is a virtual object, return the thumbnail identifier for the first member.
    virtual_object_thumbnail_identifier
  end

  delegate :logger, to: :Rails

  private

  def purl_cocina_service
    @purl_cocina_service ||= PurlService.new(bare_druid, format: :json)
  end

  def mods_xml
    @mods_xml ||= ModsService.call(purl_object: self)
  end

  def purl_virtual_object
    @purl_virtual_object ||= PurlVirtualObject.new(public_cocina:)
  end

  def cocina_service_response_body
    @cocina_service_response_body ||= purl_cocina_service.response_body.presence || '{}'
  end

  # Normalize the role text to use consistent capitalization and remove trailing punctuation.
  def format_role(role_element)
    role_element.text.strip.capitalize.sub(/[.,:;]+$/, '').tr('|', '')
  end
end
