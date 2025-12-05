# frozen_string_literal: true

module Metadata
  # Component for displaying MODS metadata sections
  class ModsComponent < ViewComponent::Base
    def initialize(document:)
      @document = document
      super()
    end

    delegate :mods, to: :@document

    def render?
      @document.modsxml.present?
    end
  end
end
