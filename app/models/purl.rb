# frozen_string_literal: true

# Wrapper for working with an object from PURL
class Purl
  include ActiveSupport::Benchmarkable
  include ModsDisplay::RelatorCodes

  COLLECTION_TYPES = %w(collection set).freeze

  attr_reader :druid

  # @param druid [String] the PURL identifier (Druid), e.g. 'druid:abc123'
  # @example
  #   Purl.new('druid:abc123')
  def initialize(druid)
    @druid = druid
  end

  delegate :exists?, to: :purl_service

  # @return [Nokogiri::XML::Document] the public XML document for this Purl object
  def public_xml
    @public_xml ||= Nokogiri::XML(purl_service.response_body)
  end

  # @return [Array<Purl>] array of Purl objects for the collections this Purl belongs to
  def collections
    @collections ||= PurlCollections.call(public_xml)
  end

  # @return [Boolean] true if this Purl object is a collection, false otherwise
  def collection?
    public_xml.xpath('//objectType').any? { |n| COLLECTION_TYPES.include? n.text.downcase }
  end

  # @return [Array<String>] array of collection member druids for this Purl object
  def collection_member_druids
    @collection_member_druids ||= collection? ? PurlCollectionMemberDruids.call(druid) : []
  end

  # @return [String] the bare druid identifier without the 'druid:' prefix
  def bare_druid
    @bare_druid ||= druid.delete_prefix('druid:')
  end

  # @return [Stanford::Mods::Record] this object includes method for accessing MODS fields
  # in a more convenient way, see: https://github.com/sul-dlss/stanford-mods/
  def smods_rec
    @smods_rec ||= Stanford::Mods::Record.new.tap do |smods_rec|
      smods_rec.from_str(mods_xml.to_s)
    end
  end

  # @return [String] the value of the type attribute for a DOR object's contentMetadata
  #  more info about these values is here:
  #  https://consul.stanford.edu/display/chimera/DOR+content+types%2C+resource+types+and+interpretive+metadata
  #  https://consul.stanford.edu/spaces/chimera/pages/137495027/Summary+of+Content+and+Resource+Types+models+and+their+behaviors
  def dor_content_type
    public_xml.xpath('//contentMetadata/@type').text
  end

  # @return [String] the value of the objectLabel in the identityMetadata section of the public XML
  def identity_md_obj_label
    public_xml.xpath('/publicObject/identityMetadata/objectLabel').first&.content
  end

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

  # @return [ModsDisplay::HTML] the imprint display value, formatted as HTML
  def imprint_display
    @imprint_display ||= ModsDisplay::HTML.new(smods_rec).mods_field(:imprint)
  end

  delegate :logger, to: :Rails

  private

  def purl_service
    @purl_service ||= PurlService.new(bare_druid)
  end

  def mods_xml
    @mods_xml ||= PurlModsService.call(public_xml)
  end

  # Normalize the role text to use consistent capitalization and remove trailing punctuation.
  def format_role(role_element)
    role_element.text.strip.capitalize.sub(/[.,:;]+$/, '').tr('|', '')
  end
end
