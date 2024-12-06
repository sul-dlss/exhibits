# frozen_string_literal: true

# Format role hierarchy for display
class RoleFacetItemPresenter < Blacklight::FacetItemPivotPresenter
  def label
    role, name = value.split('|', 2)
    return role if name.blank?

    name
  end

  def constraint_label
    value.split('|', 2).join(': ')
  end
end
