# frozen_string_literal: true

##
# Override of Blacklight's CatalogHelper to override our own methods
module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  def exhibits_default_thumbnail(document, image_options)
    if document.reference?
      image_tag(
        blacklight_config.view_config(document_index_view_type).default_bibliography_thumbnail,
        image_options
      )
    elsif document.canvas?
      image_tag(
        blacklight_config.view_config(document_index_view_type).default_canvas_thumbnail,
        image_options
      )
    end
  end
end
