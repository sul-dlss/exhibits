# frozen_string_literal: true

# Button component to view additional metadata
class MetadataButtonComponent < ViewComponent::Base
  def initialize(document:, exhibit:)
    @document = document
    @exhibit = exhibit
    super()
  end

  def render?
    @document.dor_resource_type?
  end
end
