# frozen_string_literal: true

module Metadata
  module Cocina
    # Component to display Cocina contributor
    class ContributorComponent < ViewComponent::Base
      # @param cocina_record [CocinaDisplay::CocinaRecord]
      def initialize(cocina_record:)
        @cocina_record = cocina_record
        super()
      end

      attr_reader :cocina_record

      delegate :contributor_display_data, to: :@cocina_record

      def call
        render Metadata::SectionComponent.new(label: I18n.t('metadata.contributors')) do
          render Metadata::Cocina::FieldComponent.with_collection(contributor_display_data)
        end
      end

      def render?
        contributor_display_data.present?
      end
    end
  end
end
