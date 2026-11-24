# frozen_string_literal: true

# Renders an inline leaflet map for a document's geometry
class LeafletMapFieldComponent < Blacklight::MetadataFieldComponent
  def render_field_values
    @render_field_values ||= [map]
  end

  private

  def map
    tag.div(helpers.render_document_partial(@field.document, 'show_leaflet_map'),
            class: 'blacklight-heatmaps-show-map-wrapper')
  end
end
