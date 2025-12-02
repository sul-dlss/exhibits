# frozen_string_literal: true

module Metadata
  module Cocina
    # Component to display Cocina contact
    class ContactComponent < ViewComponent::Base
      # @param cocina_record [CocinaDisplay::CocinaRecord]
      def initialize(cocina_record:)
        @cocina_record = cocina_record
        super()
      end

      attr_reader :cocina_record

      delegate :contact_email_display_data, to: :cocina_record

      def call
        render Metadata::SectionComponent.new(label: I18n.t('metadata.contact')) do
          render Metadata::Cocina::FieldComponent.with_collection(contact_email_display_data)
        end
      end

      def render?
        contact_email_display_data.present?
      end
    end
  end
end
