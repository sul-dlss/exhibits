# frozen_string_literal: true

# Wrapper for working with an object from PURL
class Purl
  include ActiveSupport::Benchmarkable
  include ModsDisplay::RelatorCodes

  attr_reader :druid

  def initialize(druid)
    @druid = druid
  end

  def exists?
    public_xml_record.public_xml.present?
  rescue HTTP::Error
    false
  end

  delegate :collection_member_druids, :collection?, to: :public_xml_record

  def public_xml_record
    @public_xml_record ||= PublicXmlRecord.new(bare_druid)
  end

  def bare_druid
    @bare_druid ||= druid.sub(/^druid:/, '')
  end

  def public_xml
    public_xml_record.public_xml_doc
  end

  def smods_rec
    @smods_rec ||= Stanford::Mods::Record.new.tap do |smods_rec|
      smods_rec.from_str(public_xml_record.mods.to_s)
    end
  end

  def collections
    @collections ||= public_xml_record.collections.map do |record|
      Purl.new(record.druid)
    end
  end

  # the value of the type attribute for a DOR object's contentMetadata
  #  more info about these values is here:
  #    https://consul.stanford.edu/display/chimera/DOR+content+types%2C+resource+types+and+interpretive+metadata
  #    https://consul.stanford.edu/display/chimera/Summary+of+Content+Types%2C+Resource+Types+and+their+behaviors
  # @return [String]
  def dor_content_type
    public_xml.xpath('//contentMetadata/@type').text
  end

  def identity_md_obj_label
    public_xml.xpath('/publicObject/identityMetadata/objectLabel').first&.content
  end

  # Normalize the MODS names to just the display name and roles.
  # @return [Array<Hash>] an array of hashes with keys `name` and `roles`
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

  def imprint_display
    @imprint_display ||= ModsDisplay::HTML.new(smods_rec).mods_field(:imprint)
  end

  delegate :logger, to: :Rails

  private

  # Normalize the role text to use consistent capitalization and remove trailing punctuation.
  def format_role(role_element)
    role_element.text.strip.capitalize.sub(/[.,:;]+$/, '').tr('|', '')
  end
end
