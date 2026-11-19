# frozen_string_literal: true

# Override the default spotlight viewer to pick between mirador 3, an oembed viewer, or the default OSD viewer
# depending on the document.
class CustomViewerComponent < Blacklight::Component
  attr_reader :document, :presenter, :view_config, :classes, :block_context

  # The parts of a SirTrevor block that are relevant to a single document
  SirTrevorBlock = Struct.new(:maxheight, :item) do
    # @return [String] the IIIF canvas the viewer should select
    def canvas_id
      item&.dig(0, 'iiif_canvas_id')
    end

    def initial_viewer_config
      config = item&.dig(0, 'iiif_initial_viewer_config')
      config unless config == 'undefined'
    end
  end

  def initialize(presenter:, view_config: nil, block_context: nil, **)
    super()

    @presenter = presenter
    @document = presenter.document
    @view_config = view_config
    @block_context = block_for_document(block_context)
  end

  # In the context of an exhibit's catalog, render the exhibit's configured viewer.
  # Elsewhere (e.g. a feature page or the global catalog) render the default viewer.
  def exhibit_mirador_viewer?
    params[:controller] == 'spotlight/catalog' && current_exhibit.required_viewer.mirador?
  end

  delegate :current_exhibit, to: :helpers

  def oembed_url
    @oembed_url ||= if helpers.feature_flags.uat_embed? && document['druid'].present?
                      format(Settings.purl.uat_url, druid: document['druid'])
                    else
                      document.first(helpers.blacklight_config.show.oembed_field)
                    end
  end

  private

  def block_for_document(block_context)
    item = block_context&.item&.select { |_key, value| value['id'] == @document.id }
    SirTrevorBlock.new(maxheight: block_context&.maxheight, item: item&.values)
  end
end
