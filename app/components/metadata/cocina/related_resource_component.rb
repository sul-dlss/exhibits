# frozen_string_literal: true

module Metadata
  module Cocina
    # A component for rendering a resource related to the current object.
    class RelatedResourceComponent < ViewComponent::Base
      def initialize(related_resource:)
        @related_resource = related_resource
        super()
      end

      def call
        content_tag :dl do
          render Metadata::Cocina::FieldComponent.with_collection(@related_resource.display_data)
        end
      end

      def render?
        @related_resource.present?
      end
    end
  end
end
