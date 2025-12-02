# frozen_string_literal: true

module Metadata
  module Cocina
    # Component to display Cocina access conditions
    class AccessConditionsComponent < ViewComponent::Base
      # @param cocina_record [CocinaDisplay::CocinaRecord]
      def initialize(cocina_record:)
        @cocina_record = cocina_record
        super()
      end

      attr_reader :cocina_record

      delegate :use_and_reproduction_display_data, :copyright_display_data,
               :license_display_data, to: :cocina_record

      def call
        render Metadata::SectionComponent.new(label: I18n.t('metadata.access')) do
          render Metadata::Cocina::FieldComponent.with_collection(access_conditions)
        end
      end

      def render?
        access_conditions.present?
      end

      private

      def access_conditions
        @access_conditions ||= [use_and_reproduction_display_data,
                                copyright_display_data,
                                license_display_data].compact.flatten
      end
    end
  end
end
