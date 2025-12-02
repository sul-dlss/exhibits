# frozen_string_literal: true

module Metadata
  module Mods
    # Component to display MODS access conditions
    class AccessConditionsComponent < ViewComponent::Base
      def initialize(mods:)
        @mods = mods
        super()
      end

      def call
        render Metadata::SectionComponent.new(label: I18n.t('metadata.access')) do
          safe_join(access_conditions)
        end
      end

      def render?
        access_conditions.present?
      end

      private

      def access_conditions
        @access_conditions ||= @mods.accessCondition.map do |access_condition|
          content_tag(:dt, access_condition.label) +
            content_tag(:dd, access_condition.values.to_sentence.html_safe) # rubocop:disable Rails/OutputSafety
        end
      end
    end
  end
end
