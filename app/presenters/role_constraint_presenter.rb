# frozen_string_literal: true

# Format role hierarchy constraints to include both the role and the name
class RoleConstraintPresenter < Blacklight::ConstraintPresenter
  def constraint_label
    facet_item_presenter.value.split('|', 2).join(': ')
  end
end
