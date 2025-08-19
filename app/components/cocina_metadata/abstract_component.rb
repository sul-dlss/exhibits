# frozen_string_literal: true

# Render the Cocina metadata component
module CocinaMetadata
  # Renders the abstract section for Cocina metadata display
  class AbstractComponent < ViewComponent::Base
    ABSTRACT_TYPES = %w(abstract summary).freeze
    TOC_TYPES = ['table of contents'].freeze

    # Example: cf386wt1778, hp566jq8781
    def initialize(document:)
      @document = document
      super()
    end

    def call
      render MetadataComponent.new(field_labels_with_values:)
    end

    def metadata?
      abstract.any? || toc.any?
    end

    private

    def field_labels_with_values
      metadata_hash(abstract).merge(metadata_hash(toc))
    end

    # TODO: Evaluate where else we might need to call flatten_nested_values
    def metadata_hash(values)
      values.each_with_object(Hash.new { |h, k| h[k] = [] }) do |n, hash|
        hash[label(n)] << CocinaDisplay::Utils.flatten_nested_values(n).pluck('value').join(' -- ')
      end
    end

    def label(hash)
      hash['displayLabel'] || hash['type']
    end

    def abstract
      @abstract ||= @document.cocina_record.path('$.description.note.*').to_a.select do |n|
        ABSTRACT_TYPES.include?(n['type'])
      end
    end

    def toc
      @toc ||= @document.cocina_record.path('$.description.note.*').to_a.select do |n|
        TOC_TYPES.include?(n['type'])
      end
    end
  end
end
