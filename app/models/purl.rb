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
  delegate :cocina_doc, :collection?, :containing_collections,
           :coordinates_as_envelope, :coordinates_as_point,
           :virtual_object?, :virtual_object_members, to: :cocina_record
  delegate :box, :folder, :physical_location, :series, to: :cocina_physical_location

  # @return [Array<Purl>] array of Purl objects for the collections this Purl belongs to
  def collections
    @collections ||= containing_collections.map { Purl.new(it) }
  end

  # @return [Array<String>] array of collection member druids for this Purl object
  def collection_member_druids
    @collection_member_druids ||= collection? ? PurlCollectionMemberDruids.call(druid) : []
  end

  # @return [String] the bare druid identifier without the 'druid:' prefix
  def bare_druid
    @bare_druid ||= druid.delete_prefix('druid:')
  end

  # @return [CocinaDisplay::CocinaRecord] an object from the cocina-display gem that provides
  # methods for accessing Cocina metadata for indexing and display
  def cocina_record
    @cocina_record ||= CocinaDisplay::CocinaRecord.new(JSON.parse(purl_cocina_service.response_body.presence || '{}'))
  end

  # @return [CocinaPhysicalLocation] an object that provides methods for accessing
  # physical location information from the Cocina record for indexing and display
  def cocina_physical_location
    @cocina_physical_location ||= CocinaPhysicalLocation.new(cocina_record:)
  end

  # @return [String] the thumbnail identifier for this PURL object or the first
  # virtual object member if this is a virtual object
  def thumbnail_identifier
    @thumbnail_identifier ||= thumbnail_purl.cocina_record.thumbnail_file&.iiif_id
  end

  # @return [String] the thumbnail URL for this PURL object or the first
  # virtual object member if this is a virtual object
  def thumbnail_url(region: 'full', width: '!400', height: '400')
    thumbnail_purl.cocina_record.thumbnail_url(region:, width:, height:)
  end

  # @return [Array<String>] an array of coordinates in either envelope or point format for indexing
  def coordinates_as_envelope_or_points
    return coordinates_as_envelope if coordinates_as_envelope.any?

    coordinates_as_point
  end

  delegate :logger, to: :Rails

  private

  def purl_cocina_service
    @purl_cocina_service ||= PurlService.new(bare_druid, format: :json)
  end

  # Normalize the role text to use consistent capitalization and remove trailing punctuation.
  def format_role(role_element)
    role_element.text.strip.capitalize.sub(/[.,:;]+$/, '').tr('|', '')
  end

  def thumbnail_purl
    @thumbnail_purl ||= virtual_object? ? Purl.new(virtual_object_members.first) : self
  end
end
