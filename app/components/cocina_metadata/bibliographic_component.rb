# frozen_string_literal: true

# Render the Cocina metadata component
module CocinaMetadata
  # Renders the bibliographic section for Cocina metadata display
  class BibliographicComponent < ViewComponent::Base
    NOTE_TYPES_TO_EXCLUDE = ['table of contents', 'abstract', 'summary', 'preferred citation'].freeze

    def initialize(document:)
      @document = document
      super()
    end

    def call
      render MetadataComponent.new(field_labels_with_values:)
    end

    def metadata?
      field_labels_with_values.any?
    end

    private

    # TODO: implement relatedItem and nestedRelatedItem
    # TODO: audience is handled as a note in cocina (as far as I can tell)?
    def field_labels_with_values
      note_hash.merge(identifiers_hash).merge(url_hash).merge(location_hash)
    end

    def note_hash
      @note_hash ||= note.each_with_object(Hash.new { |h, k| h[k] = [] }) do |n, hash|
        hash[note_label(n)] << n['value'] # TODO: generate links if value is a link?, split_on_white_space?
      end
    end

    def note_label(hash)
      hash['displayLabel'] || hash['type'] || 'note'
    end

    # cf386wt1778
    def note
      @note ||= @document.cocina_record.path('$.description.note.*').to_a.reject do |n|
        NOTE_TYPES_TO_EXCLUDE.include?(n['type'])
      end
    end

    def identifiers_hash
      @identifiers_hash ||= identifiers.each_with_object(Hash.new { |h, k| h[k] = [] }) do |id, hash|
        hash[identifier_label(id)] << id['value']
      end
    end

    def identifier_label(hash)
      hash['displayLabel'] || hash['type'] || 'identifier'
    end

    def identifiers
      @identifiers ||= @document.cocina_record.path('$.description.identifier.*').to_a
    end

    def location_hash
      @location_hash ||= location.each_with_object(Hash.new { |h, k| h[k] = [] }) do |loc, hash|
        hash[location_label(loc)] << loc['value']
      end
    end

    def location_label(loc)
      loc['displayLabel'] || (loc['type'] == 'repository' ? 'repository' : 'location')
    end

    # url xt162pg0437
    # others + repository rk684yq9989
    def location
      physical_location + digital_location + access_contact + digital_repository
    end

    def physical_location
      @physical_location ||= @document.cocina_record.path('$.description.access.physicalLocation.*').to_a
    end

    def digital_location
      @digital_location ||= @document.cocina_record.path('$.description.access.digitalLocation.*').to_a
    end

    def access_contact
      @access_contact ||= @document.cocina_record.path('$.description.access.accessContact.*').to_a
    end

    def digital_repository
      @digital_repository ||= @document.cocina_record.path('$.description.access.digitalRepository.*').to_a
    end

    def url_hash
      return {} if url.blank?

      { 'location' => url.map { |u| link_to(url_link_text(u), u['value']) } }
    end

    def url_link_text(hash)
      hash['displayLabel'] || hash['value']
    end

    def url
      @url ||= @document.cocina_record.path('$.description.access.url.*').to_a
    end
  end
end
