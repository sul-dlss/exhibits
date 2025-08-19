# frozen_string_literal: true

# Render the Cocina metadata component
class CocinaMetadataComponent < ViewComponent::Base
  def initialize(document:)
    @document = document
    super()
  end

  attr_reader :document

  def render?
    # TODO: Always render metadata from cocina just for testing purposes
    # document.modsxml.blank? && document.cocina_record.present?
    document.cocina_record.present?
  end
end
