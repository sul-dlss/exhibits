# frozen_string_literal: true

require_relative 'canvas_reader'
require_relative 'macros/general'
require_relative 'macros/canvas'

require 'active_support/core_ext/object/blank'
extend Macros::General
extend Macros::Canvas

settings do
  provide 'reader_class_name', 'CanvasReader'
  provide 'processing_thread_pool', ::Settings.traject.processing_thread_pool || 1
end

to_field 'id', extract_canvas_id
to_field 'iiif_canvas_id_ssim', extract_canvas_iiif_id
to_field 'format_main_ssim', literal('Page details')
to_field 'manuscript_number_tesim', extract_canvas_parent_manuscript_number

to_fields %w(title_display title_full_display title_uniform_search), extract_canvas_label
to_field 'title_sort', extract_canvas_label_sort

to_field 'iiif_annotation_list_url_ssim', extract_canvas_annotation_list_urls
to_field 'annotation_tesim', extract_canvas_annotations
to_field 'related_document_id_ssim', extract_canvas_related_document_ids
