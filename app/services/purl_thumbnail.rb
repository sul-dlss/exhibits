# frozen_string_literal: true

# Find the thumbnail URL for this PURL object
class PurlThumbnail
  THUMBNAIL_MIME_TYPE = 'image/jp2'

  def self.call(purl_object:)
    new(purl_object: purl_object).thumbnail_identifier
  end

  attr_reader :purl_object

  # TODO: It seems like in some cases we have to follow each of 
  # the hasMembersOrders.members druids until we find one with an image file
  # Such as in, where the Cocina object doesn't have a thumbnail but the public XML does:
  # https://purl.stanford.edu/ws947mh3822.json
  # https://purl.stanford.edu/ws947mh3822.xml
  def initialize(purl_object:)
    @purl_object = purl_object
  end

  delegate :public_cocina, :bare_druid, to: :purl_object

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
