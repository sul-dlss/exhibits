# frozen_string_literal: true

# Use our StartOverButtonComponent, which links back to the site or exhibit home page
class ConstraintsComponent < Blacklight::ConstraintsComponent
  def initialize(start_over_component: StartOverButtonComponent, **)
    super
  end
end
