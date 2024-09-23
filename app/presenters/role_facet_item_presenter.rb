# frozen_string_literal: true

# Format role hierarchy for display
class RoleFacetItemPresenter < Blacklight::FacetItemPresenter
  def label
    super.split('|', 2).join(': ')
  end
end
