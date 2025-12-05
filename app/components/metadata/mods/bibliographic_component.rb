# frozen_string_literal: true

module Metadata
  module Mods
    # Component to display MODS bibliographic information
    class BibliographicComponent < ViewComponent::Base
      def initialize(mods:)
        @mods = mods
        super()
      end

      def call
        render Metadata::SectionComponent.new(label: I18n.t('metadata.bibliographic')) do
          bibliographic_info
        end
      end

      def render?
        bibliographic_info.present?
      end

      private

      delegate :split_on_white_space, to: :helpers

      def bibliographic_info
        @bibliographic_info ||= safe_join(audiences +
                                      notes +
                                      related_items +
                                      identifiers +
                                      locations)
      end

      def audiences
        @mods.audience.map { |field| mods_record_field(field) }
      end

      def notes
        @mods.note.reject { |x| x.label.match?(/Preferred citation/i) }.map do |note|
          note.values = split_on_white_space(note.values)
          mods_record_field(note)
        end
      end

      def related_items
        @mods.relatedItem.map { |field| mods_record_field(field) } << nested_related_items
      end

      def nested_related_items
        @mods.nestedRelatedItem(raw: true).to_html
      end

      def identifiers
        @mods.identifier.map { |field| mods_record_field(field) }
      end

      def locations
        @mods.location.map { |field| mods_record_field(field) }
      end
    end
  end
end
