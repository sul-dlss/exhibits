# frozen_string_literal: true

# Overrides the default Blacklight FacetFieldPaginationComponent in order to
# use a primary (rather than secondary) outline style for the facet modal's buttons
class FacetPaginationComponent < Blacklight::FacetFieldPaginationComponent
  def initialize(button_classes: %w(btn btn-outline-primary), **)
    super
  end
end
