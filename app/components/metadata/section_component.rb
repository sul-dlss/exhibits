# frozen_string_literal: true

module Metadata
  # Component for displaying a metadata section
  class SectionComponent < ViewComponent::Base
    def initialize(label:)
      @label = label.delete_suffix(':')
      super()
    end

    attr_reader :label
  end
end
