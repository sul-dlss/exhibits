# frozen_string_literal: true

module Metadata
  module Cocina
    # A component for rendering a resource related to the current object.
    class RelatedResourceComponent < ViewComponent::Base
      # @param related_resource [CocinaDisplay::RelatedResource]
      def initialize(related_resource:)
        @related_resource = related_resource
        super()
      end

      delegate :display_data, to: :@related_resource

      def summary
        return @related_resource.to_s unless @related_resource.url?

        Metadata::Cocina::LabeledLinkComponent.new(url: @related_resource.url, link_text: @related_resource.to_s).call
      end

      def render?
        @related_resource.present?
      end
    end
  end
end
