# frozen_string_literal: true

# thumbnail component that adds a iiif icon when the document has a manifest
class ThumbnailWithIiifComponent < Blacklight::Document::ThumbnailComponent
  def exhibit_specific_manifest
    @document.exhibit_specific_manifest(@current_exhibit&.required_viewer&.custom_manifest_pattern)
  end
end
