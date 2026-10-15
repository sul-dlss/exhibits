# frozen_string_literal: true

# Display the embed iframe for an exhibit configured to use the Mirador 3 viewer,
# using the exhibit's custom manifest pattern (if any) to find the manifest.
class Mirador3ViewerComponent < EmbeddedMiradorComponent
  def initialize(document:, exhibit:)
    @exhibit = exhibit
    super(document:, block: nil)
  end

  attr_reader :exhibit

  def render?
    manifest_url.present?
  end

  def manifest_url
    @manifest_url ||= document.exhibit_specific_manifest(exhibit.required_viewer.custom_manifest_pattern)
  end

  def parameters
    { url: manifest_url, enable_comparison: true, canvas_id: document.canvas.iiif_id }
  end
end
