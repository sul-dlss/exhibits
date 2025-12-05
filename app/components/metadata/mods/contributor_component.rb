# frozen_string_literal: true

module Metadata
  module Mods
    # Component to display MODS contributor
    class ContributorComponent < ViewComponent::Base
      def initialize(mods:)
        @mods = mods
        super()
      end

      def call
        render Metadata::SectionComponent.new(label: I18n.t('metadata.contributors')) do
          safe_join(names)
        end
      end

      def render?
        names.present?
      end

      private

      def names
        @names ||= @mods.name.map { |field| mods_name_field(field) }
      end
    end
  end
end
