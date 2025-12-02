# frozen_string_literal: true

module Metadata
  module Cocina
    # Component to display Cocina abstract and contents metadata
    class SubjectComponent < ViewComponent::Base
      # @param cocina_record [CocinaDisplay::CocinaRecord]
      def initialize(cocina_record:)
        @cocina_record = cocina_record
        super()
      end

      attr_reader :cocina_record

      delegate :subject_display_data, :genre_display_data, to: :cocina_record

      def call
        render Metadata::SectionComponent.new(label: I18n.t('metadata.subjects')) do
          render Metadata::Cocina::FieldComponent.with_collection(subjects_and_genres)
        end
      end

      def render?
        subjects_and_genres.present?
      end

      private

      def subjects_and_genres
        @subjects_and_genres ||= [subject_display_data, genre_display_data].compact.flatten
      end
    end
  end
end
