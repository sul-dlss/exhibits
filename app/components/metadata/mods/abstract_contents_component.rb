# frozen_string_literal: true

module Metadata
  module Mods
    # Component to display MODS abstract and contents
    class AbstractContentsComponent < ViewComponent::Base
      def initialize(mods:)
        @mods = mods
        super()
      end

      def call
        render Metadata::SectionComponent.new(label: I18n.t('metadata.abstract')) do
          abstracts_and_contents
        end
      end

      def render?
        abstracts_and_contents.present?
      end

      private

      delegate :split_on_white_space, to: :helpers

      def abstracts_and_contents
        @abstracts_and_contents ||= safe_join(abstracts + contents)
      end

      def abstracts
        @mods.abstract.map do |abstract|
          abstract.values = split_on_white_space(abstract.values)
          mods_record_field(abstract)
        end
      end

      def contents
        @mods.contents.map do |content|
          content.values = split_on_white_space(content.values)
          mods_record_field(content)
        end
      end
    end
  end
end
