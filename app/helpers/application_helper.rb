# frozen_string_literal: true

# :nodoc:
module ApplicationHelper
  # Collection titles are indexed as a compound druid + title; we need to
  # unmangle it for display.
  def collection_title(value, separator: '-|-')
    value.split(separator).first
  end

  def document_collection_title(value:, **)
    Array(value).map { |v| collection_title(v) }.to_sentence
  end

  def document_leaflet_map(document:, **)
    render_document_partial(document, 'show_leaflet_map_wrapper')
  end

  ##
  # @param [String] manifest
  def iiif_drag_n_drop(manifest, width: '40px')
    link_url = format Settings.iiif_dnd_base_url, query: { manifest: manifest }.to_query
    link_to link_url, class: 'iiif-dnd pull-right', data: { turbolinks: false } do
      image_tag 'iiif-drag-n-drop.svg', width: width, alt: 'IIIF Drag-n-drop'
    end
  end

  ##
  # Renders a viewer for an object with understanding of the context. In the
  # context of spotlight/catalog render the configured viewer. In other contexts
  # (feature page) render the default viewer
  # @param [SolrDocument] document
  def render_viewer_in_context(document)
    if params[:controller] == 'spotlight/catalog'
      render current_exhibit.required_viewer, document: document
    else
      render current_exhibit.required_viewer.default_viewer_path, document: document
    end
  end
end
