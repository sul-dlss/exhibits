# frozen_string_literal: true

module Metadata
  module Cocina
    # Component to display Cocina values
    class ValueComponent < ViewComponent::Base
      # @param values [Array<String>] the values to display
      def initialize(values:)
        @values = values
        super()
      end

      def call
        @values.map do |value|
          tag.dd auto_link(value)
        end.join.html_safe # rubocop:disable Rails/OutputSafety
      end

      def render?
        @values.present?
      end
    end
  end
end
