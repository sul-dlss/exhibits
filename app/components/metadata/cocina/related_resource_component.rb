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

      def summary
        @related_resource.display_data.first.values.join('; ')
      end

      def display_data
        @related_resource.display_data.drop(1)
      end

      def render?
        @related_resource.present?
      end
    end
  end
end
