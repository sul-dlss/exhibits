# frozen_string_literal: true

module Metadata
  module Cocina
    # A component for rendering resources related to the current object.
    class RelatedResourcesFieldComponent < ViewComponent::Base
      # @param [CocinaDisplay::DisplayData] related_resources_field
      def initialize(related_resources_field:)
        @related_resources_field = related_resources_field
        super()
      end

      attr_accessor :related_resources_field

      delegate :label, to: :related_resources_field

      def render?
        related_resources_field.present?
      end

      def child_components
        related_resources.map { |related_resource| child_component(related_resource) }
      end

      private

      def related_resources
        related_resources_field.objects
      end

      # If the related resource has a URL, render it has a labeled link.
      # Otherwise, render it using the nested presentation (e.g. Parker citations).
      # @param [CocinaDisplay::RelatedResource] related_resource
      def child_component(related_resource)
        if related_resource.url?
          Metadata::Cocina::LabeledLinkComponent.new(url: related_resource.url, link_text: related_resource.to_s)
        else
          RelatedResourceComponent.new(related_resource: related_resource)
        end
      end
    end
  end
end
