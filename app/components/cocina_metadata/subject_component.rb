# frozen_string_literal: true

# Render the Cocina metadata component
module CocinaMetadata
  # Renders the contributor section for Cocina metadata display
  class SubjectComponent < ViewComponent::Base
    TYPES_TO_EXCLUDE = ['point coordinates', 'classification', 'coverage', 'bounding box coordinates'].freeze

    def initialize(document:)
      @document = document
      super()
    end

    def call
      render MetadataComponent.new(field_labels_with_values:)
    end

    def metadata?
      filtered_subjects.present? || genres.present?
    end

    private

    def field_labels_with_values
      subjects.merge(genres_hash) do |_key, old_val, new_val|
        old_val + new_val
      end
    end

    def subjects
      filtered_subjects.each_with_object(Hash.new { |h, k| h[k] = [] }) do |subject, hash|
        hash[label(subject)] << subject.to_s
      end
    end

    def genres_hash
      return {} if genres.blank?

      { 'genre' => genres }
    end

    def genres
      @genres ||= @document.cocina_record.genres
    end

    def label(subject)
      subject.cocina['displayLabel'] || (subject.type == 'genre' ? subject.type : 'subject')
    end

    def filtered_subjects
      @document.cocina_record.send(:subjects).reject { |s| TYPES_TO_EXCLUDE.include?(s.type) }
    end
  end
end
