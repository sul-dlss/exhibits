# frozen_string_literal: true

# Render a metadata section
class MetadataSectionComponent < ViewComponent::Base
  def initialize(document:, section:, component:)
    @document = document
    @section = section
    @component = component
    super
  end

  def heading
    t("metadata.#{@section}")
  end

  def metadata
    render component
  end

  def component
    @component.new(document: @document)
  end

  def render?
    component.metadata?
  end
end
