# frozen_string_literal: true

# :nodoc:
module ApplicationHelper
  # Collection titles are indexed as a compound druid + title; we need to
  # unmangle it for display.
  def collection_title(value, separator: '-|-')
    value.split(separator).last
  end

  def document_collection_title(value:, **)
    Array(value).map { |v| collection_title(v) }.to_sentence
  end

  def document_leaflet_map(document:, **)
    render_document_partial(document, 'show_leaflet_map_wrapper')
  end

  ##
  # @param [String] manifest
  def iiif_drag_n_drop(manifest, width: '40')
    link_url = format Settings.iiif_dnd_base_url, query: { manifest: manifest }.to_query
    link_to link_url, class: 'iiif-dnd pull-right', data: { turbolinks: false } do
      image_tag 'iiif-drag-n-drop.svg', width: width, alt: 'IIIF Drag-n-drop'
    end
  end

  ##
  # Renders a viewer for an object with understanding of the context. In the
  # context of spotlight/catalog render the configured viewer. In other contexts
  # (feature page) render the default viewer. Now passes through a "block" from
  # SirTrevor, used for rendering viewers in specific ways (canvas index).
  # @param [SolrDocument] document
  # @param [SirTrevorRails::Blocks::SolrDocumentsEmbedBlock] block
  def render_viewer_in_context(document, block)
    canvas = choose_canvas_id(block)
    if params[:controller] == 'spotlight/catalog'
      render current_exhibit.required_viewer, document: document, block: block, canvas: canvas
    else
      render current_exhibit.required_viewer.default_viewer_path, document: document, block: block, canvas: canvas
    end
  end

  ##
  #
  # @param [SolrDocument] document
  # @param [Integer] canvas_id
  def custom_render_oembed_tag_async(document, canvas_id, block)
    url = context_specific_oembed_url(document)

    content_tag :div, '', data: {
      embed_url: blacklight_oembed_engine.embed_url(
        url: url,
        canvas_id: canvas_id,
        search: params[:search],
        maxheight: block&.maxheight&.presence || '600',
        suggested_search: (current_search_session&.query_params || {})[:q]
      )
    }
  end

  ##
  # This method sends the message of which IIIF canvas should be selected by the sul-embed viewer.
  # @param [SirTrevorRails::Blocks::SolrDocumentsEmbedBlock] block
  # @return [String] Selected canvas URI
  def choose_canvas_id(sir_trevor_block)
    sir_trevor_block.try(:items).try(:first).try(:[], 'iiif_canvas_id')
  end

  def context_specific_oembed_url(document)
    if feature_flags.uat_embed? && document['druid'].present?
      format(Settings.purl.uat_url, druid: document['druid'])
    else
      document.first(blacklight_config.show.oembed_field)
    end
  end
end
