# frozen_string_literal: true

module Metadata
  # Component for displaying Cocina metadata sections
  class CocinaComponent < ViewComponent::Base
    def initialize(document:)
      @document = document
      super()
    end

    delegate :cocina_record, to: :purl

    # TODO: In future work we will want something indexed to indicate whether
    #       we should display metadata from Cocina.
    def render?
      Settings.cocina.metadata_display_source
    end

    def purl
      @purl || Purl.new(@document.id)
    end
  end
end
