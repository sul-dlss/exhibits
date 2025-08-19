# frozen_string_literal: true

# Render the Cocina metadata component
module CocinaMetadata
  # Renders the description section for Cocina metadata display
  class DescriptionComponent < ViewComponent::Base
    FORMS_TO_EXCLUDE = ['genre', 'reformatting quality', 'map scale', 'map projection', 'media type'].freeze
    MAP_FORMS = ['map scale', 'map projection'].freeze

    def initialize(document:)
      @document = document
      super()
    end

    def call
      render MetadataComponent.new(field_labels_with_values:)
    end

    def metadata?
      true
    end

    def field_labels_with_values
      form_type_hash.merge(imprint_hash).merge(imprint_notes_hash).merge(language_hash).merge(extent_notes_hash).merge(cartographics_hash)
    end

    # TODO: needs to include titles other than the main title and labels
    #       this will likely require changes to cocina display so we retain the
    #       types/displayLabels

    def imprint_hash
      return {} if imprint.blank?

      { imprint: imprint }
    end

    # TODO: Should date created be part of this?
    # See https://purl.stanford.edu/cf386wt1778.json
    # It looks like with mods we're doing something clever and if we
    # only have an imprint date we use a label other than imprint=> Date created
    def imprint
      @imprint ||= @document.cocina_record.imprint_str
    end

    def imprint_notes_hash
      @imprint_notes_hash ||= imprint_notes.each_with_object(Hash.new { |h, k| h[k] = [] }) do |n, hash|
        hash[imprint_label(n)] << n['value']
      end
    end

    def imprint_label(hash)
      hash['displayLabel'] || hash['type'] || 'imprint note'
    end

    def imprint_notes
      @imprint_notes ||= @document.cocina_record.imprint_events.map(&:cocina).pluck('note').flatten
    end

    # NOTE: this includes "resourceType," "form," and "extent" from mods_description
    #       but I'm not sure if we care about the display order (ordered as above)?
    def form_type_hash
      @form_type_hash ||= form_type.each_with_object(Hash.new { |h, k| h[k] = [] }) do |n, hash|
        hash[form_type_label(n)] << n['value']
      end
    end

    def form_type_label(hash)
      hash['displayLabel'] || (['resource type', 'extent', 'digital origin'].include?(hash['type']) ? hash['type'] : 'form')
    end

    def form_type
      @document.cocina_record.path('$.description.form.*').to_a.reject do |f|
        FORMS_TO_EXCLUDE.include?(f['type'])
      end
    end

    def language_hash
      return {} if language.blank?

      { language: language }
    end

    def language
      @language ||= @document.cocina_record.searchworks_language_names.join(', ')
    end

    def extent_notes_hash
      @extent_notes_hash ||= extent_notes.each_with_object(Hash.new { |h, k| h[k] = [] }) do |n, hash|
        hash[extent_notes_label(n)] << n['value']
      end
    end

    def extent_notes_label(hash)
      hash['displayLabel'] || hash['type'] || 'extent note'
    end

    def extent_notes
      @extent_notes ||= @document.cocina_record.path('$.description.form.*.note.*').to_a
    end

    def cartographics_hash
      return {} if cartographics.blank?

      { 'map info' => cartographics }
    end

    def cartographics
      map_forms.pluck('value') + geographic
    end

    def geographic
      @document.cocina_record.coordinates
    end

    def map_forms
      @document.cocina_record.path('$.description.form.*').to_a.select do |f|
        MAP_FORMS.include?(f['type'])
      end
    end
  end
end
