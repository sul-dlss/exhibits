# frozen_string_literal: true

# Button component to view additional metadata
class MetadataButtonComponent < ViewComponent::Base
  def initialize(document:, exhibit:)
    @document = document
    @exhibit = exhibit
    super()
  end

  # TODO: We're going to want something indexed to tell us whether to show this button
  #       for cocina records.
  def render?
    @document.modsxml.present? || Settings.cocina.display_metadata
  end
end
