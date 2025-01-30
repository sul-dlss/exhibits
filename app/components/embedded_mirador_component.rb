# frozen_string_literal: true

# Display the embed iframe
class EmbeddedMiradorComponent < ViewComponent::Base
  def initialize(document:)
    @document = document
    super
  end

  attr_reader :document

  delegate :iiif_drag_n_drop, to: :helpers

  def render?
    document.manifest_url.present?
  end

  def manifest_url
    @manifest_url ||= doc_manifest.starts_with?('/') ? root_url + doc_manifest.slice(1..-1) : doc_manifest
  end

  def iframe_src
    "#{Settings.iiif_embed.url}?#{{ url: manifest_url }.to_query}"
  end

  def doc_manifest
    document.manifest_url
  end
end
