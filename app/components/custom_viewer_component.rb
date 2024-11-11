# frozen_string_literal: true

# Override the default spotlight viewer to pick between mirador 3, an oembed viewer, or the default OSD viewer
# depending on the document.
class CustomViewerComponent < Blacklight::Component
  attr_reader :document, :presenter, :classes, :block_context

  def initialize(document:, presenter:, view_config: nil, block_context: nil, **kwargs)
    super

    @document = document
    @presenter = presenter
    @view_config = view_config
    @block_context = block_context
  end
end
