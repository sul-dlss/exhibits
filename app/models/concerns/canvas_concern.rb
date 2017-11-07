# frozen_string_literal: true

##
# A concern to be mixed into SolrDocument for accessing a document's annotationlist
module CanvasConcern
  def canvas?
    first('format_main_ssim') == 'Page details'
  end

  def canvas
    return unless canvas?
    Canvas.new(
      id,
      first('iiif_canvas_id_ssim'),
      first('title_display'),
      fetch('iiif_annotation_list_url_ssim', []),
      fetch('annotation_tesim', [])
    )
  end
end
