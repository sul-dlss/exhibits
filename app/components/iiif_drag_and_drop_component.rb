# frozen_string_literal: true

# Renders the IIIF drag-n-drop icon linking to a IIIF manifest
class IiifDragAndDropComponent < ViewComponent::Base
  strip_trailing_whitespace

  # @param [String] manifest the IIIF manifest URL
  # @param [SolrDocument] document
  # @param [String] width the width of the icon
  def initialize(manifest:, document:, width: '30')
    @manifest = manifest
    @document = document
    @width = width
    super()
  end

  attr_reader :manifest, :document, :width

  def render?
    manifest.present?
  end

  def link_url
    format Settings.iiif_dnd_base_url, query: { manifest: }.to_query
  end

  def aria_label
    "IIIF Drag-n-drop: #{document['title_display']}"
  end
end
