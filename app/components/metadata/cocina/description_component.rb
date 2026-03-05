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
               :event_note_display_data, :event_date_display_data,
               :publication_display_data, :title_display_data, to: :cocina_record

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
        @description ||= [title_display_data(exclude_primary: true),
                          form_display_data,
                          publication_display_data,
                          event_date_display_data,
                          event_note_display_data,
                          language_display_data,
                          form_note_display_data,
                          map_display_data].compact.flatten
      end
    end
  end
end
