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

      def toggle_button
        return unless toggle_button_visible?

        tag.button 'Expand all',
                   class: 'btn btn-link text-uppercase align-baseline py-0',
                   data: { action: 'details-container#toggleDetails',
                           details_container_target: 'toggleButton' }
      end

      private

      def related_resources
        related_resources_field.objects
      end

      def toggle_button_visible?
        related_resources.none? { it.url? || it.display_data.one? }
      end

      # If the related resource has a URL, render it has a labeled link.
      # If it has only one display data entry, render it like regular values.
      # Otherwise, render it using the nested presentation (e.g. Parker citations).
      # @param [CocinaDisplay::RelatedResource] related_resource
      def child_component(related_resource)
        if related_resource.url?
          Metadata::Cocina::LabeledLinkComponent.new(url: related_resource.url, link_text: related_resource.to_s)
        elsif related_resource.display_data.one?
          Metadata::Cocina::ValueComponent.new(values: related_resource.display_data.first.values)
        else
          Metadata::Cocina::RelatedResourceComponent.new(related_resource: related_resource)
        end
      end
    end
  end
end
