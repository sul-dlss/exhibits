# frozen_string_literal: true

module Metadata
  module Cocina
    # A component for rendering an HTML link with custom link text.
    class LabeledLinkComponent < ViewComponent::Base
      def initialize(url:, link_text:)
        @url = url
        @link_text = link_text
        super()
      end

      def call
        content_tag(:p) do
          link_to(@link_text, @url)
        end
      end

      def render?
        @url.present? && @link_text.present?
      end
    end
  end
end
