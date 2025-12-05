# frozen_string_literal: true

module Metadata
  module Mods
    # Component to display MODS subjects
    class SubjectComponent < ViewComponent::Base
      def initialize(mods:)
        @mods = mods
        super()
      end

      def call
        render Metadata::SectionComponent.new(label: I18n.t('metadata.subjects')) do
          subjects_and_genres
        end
      end

      def render?
        subjects_and_genres.present?
      end

      private

      def subjects_and_genres
        @subjects_and_genres ||= safe_join(subjects + genres)
      end

      def subjects
        @mods.subject.map { |field| mods_subject_field(field) }
      end

      def genres
        @mods.genre.map { |field| mods_genre_field(field) }
      end
    end
  end
end
