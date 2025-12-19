# frozen_string_literal: true

# Find the thumbnail URL for this PURL object
class PurlThumbnail
  THUMBNAIL_MIME_TYPE = 'image/jp2'

  # @param purl_object [Purl] the PURL object for which to find the thumbnail
  # @example
  #   PurlThumbnail.new(purl_object: Purl.new('druid:abc123'))
  # @return [PurlThumbnail] instance of this class
  def initialize(purl_object:)
    @purl_object = purl_object
  end

  # @return [String, nil] the thumbnail identifier URL or nil if no thumbnail is found
  def thumbnail_identifier
    return unless thumbnail_file

    stacks_iiif_url
  end

  private

  attr_reader :purl_object

  delegate :cocina_record, :bare_druid, to: :purl_object
  delegate :files, to: :cocina_record

  def thumbnail_file
    files.find { it.fetch('hasMimeType') == THUMBNAIL_MIME_TYPE }
  end

  def stacks_iiif_url
    "#{Settings.stacks.iiif_url}/#{ERB::Util.url_encode(identifier)}"
  end

  def identifier
    "#{bare_druid}/#{thumbnail_filename.delete_suffix('.jp2')}"
  end

  def thumbnail_filename
    thumbnail_file&.fetch('filename', nil)
  end
end
