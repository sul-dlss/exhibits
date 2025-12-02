# frozen_string_literal: true

module Metadata
  module Cocina
    # Component to display a Cocina field with label and values
    class FieldComponent < ViewComponent::Base
      # @param field [CocinaDisplay::DisplayData]
      def initialize(field:)
        @field = field
        super()
      end

      def call
        tag.dt(@field.label) +
          Metadata::Cocina::ValueComponent.new(values: @field.values).call
      end

      def render?
        @field.present? && @field.values.present?
      end
    end
  end
end
