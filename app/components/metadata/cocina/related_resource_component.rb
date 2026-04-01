# frozen_string_literal: true

module Metadata
  module Cocina
    # A component for rendering a resource related to the current object.
    class RelatedResourceComponent < ViewComponent::Base
      # @param related_resource [CocinaDisplay::RelatedResource]
      # @param group_label [String, nil] the label of the enclosing field group; when the resource
      #   has no title or URL its string representation falls back to this same label, so we suppress
      #   the redundant <summary> and render display_data inline instead.
      def initialize(related_resource:, group_label: nil)
        @related_resource = related_resource
        @group_label = group_label
        super()
      end

      delegate :display_data, to: :@related_resource

      def summary
        return if @related_resource.url? || @related_resource.to_s == @group_label

        @related_resource.to_s
      end

      def labeled_link
        return unless @related_resource.url?

        link_to(@related_resource.to_s, @related_resource.url)
      end

      def render?
        @related_resource.present?
      end
    end
  end
end
