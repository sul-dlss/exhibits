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

to_field 'id', extract_record('@id') do |_record, accumulator, _context|
  accumulator.map! { |v| "canvas-#{Digest::MD5.hexdigest(v)}" }
end
to_field 'iiif_canvas_id_ssim', extract_record('@id')
to_field 'format_main_ssim', literal('Page details')
to_field 'manuscript_number_tesim', extract_record('parent_manuscript_number')
to_field 'range_labels_tesim', extract_record('range_labels')

to_fields %w(title_display title_full_display title_uniform_search), extract_canvas_label
to_field 'title_sort', extract_canvas_label_sort

to_field 'iiif_annotation_list_url_ssim', extract_canvas_annotation_list_urls
to_field 'annotation_tesim', extract_canvas_annotations
to_field 'related_document_id_ssim', extract_record('@id') do |_record, accumulator, _context|
  accumulator.map! { |v| v[Exhibits::Application.config.druid_regex] }.compact!
end
to_field 'content_metadata_type_ssm', literal('manuscript')
to_field 'iiif_manifest_url_ssi', extract_record('@id') do |_record, accumulator, _context|
  accumulator.map! do |v|
    druid = v[Exhibits::Application.config.druid_regex]
    format(Settings.purl.iiif_manifest_url, druid: druid) if druid
  end.compact!
end
