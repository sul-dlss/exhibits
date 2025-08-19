# frozen_string_literal: true

# Render the Cocina metadata component
module CocinaMetadata
  # Renders the abstract section for Cocina metadata display
  class AbstractComponent < ViewComponent::Base
    NOTE_TYPES_TO_INCLUDE = ['abstract', 'summary', 'table of contents'].freeze

    def initialize(document:)
      @document = document
      super()
    end

    def call
      render MetadataComponent.new(field_labels_with_values:)
    end

    def metadata?
      contents.any? || abstract.any?
    end

    private

    # TODO: this should probably pull from other note types too (summary?) and maybe honor displayLabel?
    def field_labels_with_values
      note_hash
    end

    def note_hash
      @note_hash ||= note.each_with_object(Hash.new { |h, k| h[k] = [] }) do |n, hash|
        hash[note_label(n)] << n['value']
      end
    end

    def note_label(hash)
      hash['displayLabel'] || hash['type']
    end

    def note
      @note ||= @document.cocina_record.path('$.description.note.*').to_a.select do |n|
        NOTE_TYPES_TO_INCLUDE.include?(n['type'])
      end
    end

    def contents_hash
      return {} if contents.blank?

      { 'table of contents' => contents } # TODO: helpers.split_on_whitespace(contents)
    end

    def abstract_hash
      return {} if abstract.blank?

      { 'abstract' => abstract } # TODO: helpers.split_on_whitespace(abstract)
    end

    def contents
      @contents ||= @document.cocina_record.path('$.description.note[?match(@.type, "table of contents")].value').to_a
    end

    def abstract
      @abstract ||= @document.cocina_record.path('$.description.note[?match(@.type, "abstract")].value').to_a
    end
  end
end
