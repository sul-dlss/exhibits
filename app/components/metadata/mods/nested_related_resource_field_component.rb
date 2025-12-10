# frozen_string_literal: true

module Metadata
  module Mods
    # Subclass of ModsDisplay::FieldComponent to render a nested related resource field
    # with an expand/collapse all button and summary/details structure
    class NestedRelatedResourceFieldComponent < ModsDisplay::FieldComponent
      def field_values
        @field_values ||= @field.values.compact_blank
      end

      def label
        @field.label.delete_suffix(':')
      end

      def render_value(value)
        return format_value(value) unless value.include?('<summary>')

        tag.details data: { action: 'details-container#toggleButtonText',
                            details_container_target: 'detailItem' } do
          format_value(value)
        end
      end

      def toggle_button
        return unless includes_summary?

        tag.button(
          'Expand all',
          class: 'btn btn-link text-uppercase align-baseline p-0 ms-1',
          data: {
            action: 'details-container#toggleDetails',
            details_container_target: 'toggleButton'
          }
        )
      end

      def includes_summary?
        field_values.any? { |value| value.include?('<summary>') }
      end
    end
  end
end
