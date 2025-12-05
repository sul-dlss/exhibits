# frozen_string_literal: true

module Metadata
  module Mods
    # Component to display MODS description
    class DescriptionComponent < ViewComponent::Base
      def initialize(mods:)
        @mods = mods
        super()
      end

      def call
        render Metadata::SectionComponent.new(label: I18n.t('metadata.description')) do
          description
        end
      end

      def render?
        description.present?
      end

      private

      def description
        @description ||= safe_join(titles +
                                   resource_types +
                                   forms +
                                   extents +
                                   imprints +
                                   languages +
                                   descriptions +
                                   cartographics)
      end

      def titles
        @mods.mods_field(:title).fields.reject { |x| x.label.match?(/^Title/i) }.map do |field|
          mods_record_field(field)
        end
      end

      def resource_types
        @mods.resourceType.map { |field| mods_record_field(field) }
      end

      def forms
        @mods.form.map { |field| mods_record_field(field) }
      end

      def extents
        @mods.extent.map { |field| mods_record_field(field) }
      end

      def imprints
        @mods.imprint.map { |field| mods_record_field(field) }
      end

      def languages
        @mods.language.map { |field| mods_record_field(field) }
      end

      def descriptions
        @mods.description.map { |field| mods_record_field(field) }
      end

      def cartographics
        @mods.cartographics.map { |field| mods_record_field(field) }
      end
    end
  end
end
