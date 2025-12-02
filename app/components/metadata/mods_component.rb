# frozen_string_literal: true

module Metadata
  # Component for displaying MODS metadata sections
  class ModsComponent < ViewComponent::Base
    def initialize(document:)
      @document = document
      super()
    end

    delegate :mods, to: :@document

    # TODO: In future work we will want something indexed to indicate whether
    #       we should display metadata from MODS or Cocina.
    def render?
      @document.modsxml.present? && !Settings.cocina.metadata_display_source
    end
  end
end
