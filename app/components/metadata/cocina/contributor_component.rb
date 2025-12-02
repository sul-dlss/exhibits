# frozen_string_literal: true

module Metadata
  module Cocina
    # Component to display Cocina contributor
    class ContributorComponent < ViewComponent::Base
      def initialize(cocina_record:)
        @cocina_record = cocina_record
        super()
      end

      def call
        render Metadata::SectionComponent.new(label: I18n.t('metadata.contributors')) do
          render Metadata::Cocina::FieldComponent.with_collection(contributors)
        end
      end

      def render?
        contributors.present?
      end

      private

      def contributors
        @contributors ||= @cocina_record.contributor_display_data.reject { |c| c.label == 'Publisher' }
      end
    end
  end
end
