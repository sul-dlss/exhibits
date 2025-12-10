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
                                      nested_related_items +
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
        @mods.relatedItem.map { |field| mods_record_field(field) }
      end

      def nested_related_items
        @mods.nestedRelatedItem(value_renderer: ::RelatedItemValueRenderer).map do |field|
          render Metadata::Mods::NestedRelatedResourceFieldComponent.new(
            field: field,
            value_transformer: nested_related_items_value_transformer
          )
        end
      end

      def nested_related_items_value_transformer
        lambda do |value|
          helpers.format_mods_html(value.to_s, tags: %w(h1 a dl dd dt i b em strong cite br summary))
        end
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
