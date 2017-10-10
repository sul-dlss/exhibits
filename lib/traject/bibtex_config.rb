# frozen_string_literal: true

require_relative 'bib_reader'
require_relative 'macros/bibtex'
require_relative 'macros/general'

require 'bibliography'
require 'active_support/core_ext/object/blank'
extend Macros::BibTeX
extend Macros::General

settings do
  provide 'reader_class_name', 'BibReader'
  provide 'processing_thread_pool', ::Settings.traject.processing_thread_pool || 1
end

each_record do |record, context|
  context.skip!("Skipping #{record.key} no key") if record.key.blank?
  context.skip!("Skipping #{record.key} no title") if record.title.blank?
  context.skip!("Skipping #{record.key} no keywords") unless record.respond_to?(:keywords)
end

to_field 'id', extract_bibtex_id
to_field 'bibtex_key_ss', extract_bibtex_key
to_field 'ref_type_ssm', extract_bibtex_field(:ref_type)
to_fields %w(title_display title_full_display title_uniform_search title_sort), extract_bibtex_field(:title)
to_fields %w(author_person_full_display author_sort), extract_bibtex_field(:author)
to_fields %w(pub_year_isi pub_year_w_approx_isi), extract_bibtex_field(:year)
to_field 'editor_ssim', extract_bibtex_field(:editor)
to_field 'book_title_ssim', extract_bibtex_field(:booktitle)
to_field 'pub_display', extract_bibtex_publication
to_field 'location_ssi', extract_bibtex_field(:address)
to_field 'university_ssim', extract_bibtex_field(:school)
to_field 'edition_ssm', extract_bibtex_field(:edition)
to_field 'series_ssi', extract_bibtex_field(:series)
to_field 'thesis_type_ssm', extract_bibtex_field(:type)
to_field 'volume_ssm', extract_bibtex_field(:volume)
to_field 'issue_ssm', extract_bibtex_field(:issue)
to_field 'pages_ssm', extract_bibtex_field(:pages)
to_field 'doi_ssim', extract_bibtex_field(:doi)
to_field 'general_notes_ssim', extract_bibtex_field(:annote, split: '|', trim: true)
to_field 'format_main_ssim', literal('Reference')
to_field 'bibtex_ts', extract_bibtex_raw
to_field 'formatted_bibliography_ts', extract_bibtex_formatted_bibliography
to_field 'related_document_id_ssim', extract_bibtex_related_document_ids
