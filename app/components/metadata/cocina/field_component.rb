# frozen_string_literal: true

module Metadata
  module Cocina
    # Component to display a Cocina field with label and values
    class FieldComponent < ViewComponent::Base
      def initialize(field:)
        @field = field
        super()
      end

      def call
        content_tag(:dt, @field.label) +
          @field.values.map do |value|
            content_tag(:dd, auto_link(value))
          end.join.html_safe # rubocop:disable Rails/OutputSafety
      end

      def render?
        @field.present? && @field.values.present?
      end
    end
  end
end
