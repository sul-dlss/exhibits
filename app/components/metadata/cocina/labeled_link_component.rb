# frozen_string_literal: true

module Metadata
  module Cocina
    # A component for rendering an HTML link with custom link text.
    class LabeledLinkComponent < ViewComponent::Base
      # @param url [String] the URL for the link
      # @param link_text [String] the text to display for the link
      def initialize(url:, link_text:)
        @url = url
        @link_text = link_text
        super()
      end

      def call
        tag.dd link_to(@link_text, @url)
      end

      def render?
        @url.present? && @link_text.present?
      end
    end
  end
end
