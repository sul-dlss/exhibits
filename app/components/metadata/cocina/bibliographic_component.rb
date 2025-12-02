# frozen_string_literal: true

module Metadata
  module Cocina
    # Component to display Cocina bibliographic metadata
    class BibliographicComponent < ViewComponent::Base
      # @param cocina_record [CocinaDisplay::CocinaRecord]
      def initialize(cocina_record:)
        @cocina_record = cocina_record
        super()
      end

      attr_reader :cocina_record

      delegate :general_note_display_data, :identifier_display_data,
               :access_display_data, :related_resource_display_data, to: :cocina_record

      def render?
        general_note_display_data.present? ||
          related_resource_display_data.present? ||
          identifier_display_data.present? ||
          access_display_data.present?
      end
    end
  end
end
