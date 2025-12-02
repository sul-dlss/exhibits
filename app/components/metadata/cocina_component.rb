# frozen_string_literal: true

module Metadata
  # Component for displaying Cocina metadata sections
  class CocinaComponent < ViewComponent::Base
    def initialize(id:)
      @id = id
      super()
    end

    delegate :cocina_record, to: :purl

    # TODO: We're going to want something indexed to tell us whether to show this button
    #       for cocina records.
    def render?
      Settings.cocina.display_metadata
    end

    def purl
      @purl || Purl.new(@id)
    end
  end
end
