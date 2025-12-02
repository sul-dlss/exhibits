# frozen_string_literal: true

module Metadata
  module Cocina
    # Component to display Cocina abstract and contents metadata
    class AbstractContentsComponent < ViewComponent::Base
      # @param cocina_record [CocinaDisplay::CocinaRecord]
      def initialize(cocina_record:)
        @cocina_record = cocina_record
        super()
      end

      attr_reader :cocina_record

      delegate :abstract_display_data, :table_of_contents_display_data, to: :cocina_record

      def call
        render Metadata::SectionComponent.new(label: I18n.t('metadata.abstract')) do
          render Metadata::Cocina::FieldComponent.with_collection(abstract_and_contents)
        end
      end

      def render?
        abstract_and_contents.present?
      end

      private

      def abstract_and_contents
        @abstract_and_contents ||= [abstract_display_data,
                                    table_of_contents_display_data].compact.flatten
      end
    end
  end
end
