# frozen_string_literal: true

# Button component to view additional metadata
class MetadataButtonComponent < ViewComponent::Base
  def initialize(document:, exhibit:)
    @document = document
    @exhibit = exhibit
    super()
  end

  # TODO: In future work we will want something indexed to indicate whether
  #       we should show this button for cocina records.
  def render?
    @document.modsxml.present? || Settings.cocina.metadata_display_source
  end
end
