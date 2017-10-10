# frozen_string_literal: true

##
# Override of Blacklight's CatalogHelper to override our own methods
module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  # @note thumbnail handling moves to a presenter in Blacklight 7.
  # Overriding Blacklight so that all references display thumbnails
  #
  # @param [SolrDocument] document
  # @return [Boolean]
  # rubocop:disable Style/PredicateName
  def has_thumbnail?(document)
    return super unless document.reference?

    true
  end
  # rubocop:enable Style/PredicateName

  # @note thumbnail handling moves to a presenter in Blacklight 7.
  # Overriding Blacklight to provide a default thumbnail for references.
  # Need to override instead of configuring a thumbnail_method because thumbnail_method
  # does not receive url_options to be passed to a link_to_document
  #
  # @param [SolrDocument] document
  # @param [Hash] image_options to pass to the image tag
  # @param [Hash] url_options to pass to #link_to_document
  # @return [String]
  def render_thumbnail_tag(document, image_options = {}, url_options = {})
    return super unless document.reference?
    image_path = blacklight_config.view_config(document_index_view_type).default_bibliography_thumbnail
    image = image_tag(image_path, image_options)
    link_to_document document, image, url_options
  end
end
