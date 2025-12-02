# frozen_string_literal: true

module Metadata
  module Mods
    # Component to display MODS contact information
    class ContactComponent < ViewComponent::Base
      def initialize(mods:)
        @mods = mods
        super()
      end

      def call
        render Metadata::SectionComponent.new(label: I18n.t('metadata.contact')) do
          safe_join(contacts)
        end
      end

      def render?
        contacts.present?
      end

      private

      def contacts
        @contacts ||= @mods.contact.map { |field| mods_record_field(field) }
      end
    end
  end
end
