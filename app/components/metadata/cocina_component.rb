# frozen_string_literal: true

module Metadata
  # Component for displaying Cocina metadata sections
  class CocinaComponent < ViewComponent::Base
    def initialize(document:)
      @document = document
      super()
    end

    delegate :cocina_record, to: :purl

    def render?
      @document.dor_resource_type?
    end

    def purl
      @purl ||= Purl.new(@document.id)
    end
  end
end
