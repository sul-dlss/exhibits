# frozen_string_literal: true

# Overrides the default Blacklight FacetGroupComponent in order to
# use a primary (rather than secondary) outline style for the facet toggle button
class FacetGroupComponent < Blacklight::Response::FacetGroupComponent
  def collapse_toggle_button(panel_id)
    render button_component.new(panel_id:, classes: 'btn btn-outline-primary facet-toggle-button d-block d-lg-none')
  end
end
