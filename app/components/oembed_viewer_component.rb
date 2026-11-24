# frozen_string_literal: true

# Draws the placeholder that the oembed javascript replaces with a sul-embed viewer
class OembedViewerComponent < ViewComponent::Base
  # @param [String] url the URL of the resource to embed
  # @param [CustomViewerComponent::SirTrevorBlock] block the SirTrevor block this viewer is rendered in (if any)
  def initialize(url:, block: nil)
    @url = url
    @block = block
    super()
  end

  attr_reader :url, :block

  def embed_path
    helpers.blacklight_oembed_engine.embed_path(
      url:,
      iiif_initial_viewer_config: block&.initial_viewer_config || params[:iiif_initial_viewer_config],
      canvas_id: block&.canvas_id || params[:canvas_id],
      search: params[:search],
      maxheight: block&.maxheight.presence || '600',
      suggested_search: (helpers.current_search_session&.query_params || {})[:q]
    )
  end
end
