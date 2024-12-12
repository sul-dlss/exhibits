# frozen_string_literal: true

class DropdownComponent < Blacklight::System::DropdownComponent
  def before_render
    # this is overriding the default button classes set in Blacklight
    # (we want to use btn-outline-primary for EarthWorks instead of btn-outline-secondary)
    with_button(label: button_label, classes: %w[btn btn-outline-primary dropdown-toggle])
    super
  end
end
