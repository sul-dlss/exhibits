# frozen_string_literal: true

# Find the thumbnail URL for this PURL object
class PurlThumbnail
  THUMBNAIL_MIME_TYPE = 'image/jp2'

  # @param purl_object [Purl] the PURL object for which to find the thumbnail
  # @example
  #   PurlThumbnail.call(purl_object: Purl.new('druid:abc123'))
  # @return [String, nil] the thumbnail identifier URL or nil if no thumbnail is found
  def self.call(purl_object:)
    new(purl_object:).thumbnail_identifier
  end

  attr_reader :purl_object

  # @param purl_object [Purl] the PURL object for which to find the thumbnail
  # @example
  #   PurlThumbnail.new(purl_object: Purl.new('druid:abc123'))
  # @return [PurlThumbnail] instance of this class
  def initialize(purl_object:)
    @purl_object = purl_object
  end

  delegate :public_cocina, :bare_druid, to: :purl_object

  # @return [String, nil] the thumbnail identifier URL or nil if no thumbnail is found
  def thumbnail_identifier
    return nil unless thumbnail_file

    stacks_iiif_url
  end

  private

  def thumbnail_filename
    thumbnail_file&.fetch('filename', nil)
  end

  def thumbnail_file
    public_cocina_contains.each do |resource|
      file = resource_contains(resource).find { |f| f.fetch('hasMimeType') == THUMBNAIL_MIME_TYPE }
      return file if file
    end
    nil
  end

  def public_cocina_contains
    resource_contains(public_cocina)
  end

  def resource_contains(resource)
    Array(resource.dig('structural', 'contains'))
  end

  def stacks_iiif_url
    "#{Settings.stacks.iiif_url}/#{ERB::Util.url_encode(identifier)}"
  end

  def identifier
    "#{bare_druid}/#{thumbnail_filename.delete_suffix('.jp2')}"
  end
end
