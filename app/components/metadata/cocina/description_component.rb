# frozen_string_literal: true

module Metadata
  module Cocina
    # Component to display Cocina description
    class DescriptionComponent < ViewComponent::Base
      # @param cocina_record [CocinaDisplay::CocinaRecord]
      def initialize(cocina_record:)
        @cocina_record = cocina_record
        super()
      end

      attr_reader :cocina_record

      delegate :form_display_data, :language_display_data,
               :form_note_display_data, :map_display_data,
               :event_note_display_data, :event_date_display_data, to: :cocina_record

      def call
        render Metadata::SectionComponent.new(label: I18n.t('metadata.description')) do
          render Metadata::Cocina::FieldComponent.with_collection(description)
        end
      end

      def render?
        description.present?
      end

      private

      def description
        @description ||= [title_display_data,
                          form_display_data,
                          publication_places,
                          publisher,
                          event_date_display_data,
                          event_note_display_data,
                          language_display_data,
                          form_note_display_data,
                          map_display_data].compact.flatten
      end

      def title_display_data
        cocina_record.title_display_data.reject { it.label == 'Title' }
      end

      def publication_places
        CocinaDisplay::DisplayData.from_strings(@cocina_record.publication_places, label: 'Place').presence
      end

      def publisher
        CocinaDisplay::DisplayData.from_strings(@cocina_record.publisher_names, label: 'Publisher').presence
      end
    end
  end
end
