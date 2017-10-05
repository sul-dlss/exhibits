# frozen_string_literal: true

require_relative 'bib_reader'
require_relative 'macros/bibtex'
require 'bibliography'
require 'active_support/core_ext/object/blank'
extend Macros::BibTeX

settings do
  provide 'reader_class_name', 'BibReader'
  provide 'processing_thread_pool', ::Settings.traject.processing_thread_pool || 1
end

each_record do |record, context|
  context.skip!("Skipping #{record.key} no key") if record.key.blank?
  context.skip!("Skipping #{record.key} no title") if record.title.blank?
  context.skip!("Skipping #{record.key} no keywords") unless record.respond_to?(:keywords)
end

to_field 'id', from_bibtex(:id)

to_field 'bibtex_key_ss', from_bibtex(:key)

to_field 'ref_type_ssm', from_bibtex(:ref_type)

to_field 'title_display', from_bibtex(:title)
to_field 'title_full_display', from_bibtex(:title)
to_field 'title_uniform_search', from_bibtex(:title)
to_field 'title_sort', from_bibtex(:title)

to_field 'author_person_full_display', from_bibtex(:author)
to_field 'author_sort', from_bibtex(:author)

to_field 'pub_year_isi', from_bibtex(:year)
to_field 'pub_year_w_approx_isi', from_bibtex(:year)

to_field 'editor_ssim', from_bibtex(:editor)

to_field 'book_title_ssim', from_bibtex(:booktitle)

to_field 'pub_display', lambda { |record, accumulator, _context|
  accumulator << record.journal.to_s.presence if record.respond_to?(:journal)
  accumulator << record.publisher.to_s.presence if record.respond_to?(:publisher)
}

to_field 'location_ssi', from_bibtex(:address)

to_field 'university_ssim', from_bibtex(:school)

to_field 'edition_ssm', from_bibtex(:edition)

to_field 'series_ssi', from_bibtex(:series)

to_field 'thesis_type_ssm', from_bibtex(:type)

to_field 'volume_ssm', from_bibtex(:volume)

to_field 'issue_ssm', from_bibtex(:issue)

to_field 'pages_ssm', from_bibtex(:pages)

to_field 'doi_ssim', from_bibtex(:doi)

to_field 'general_notes_ssim', lambda { |record, accumulator, _context|
  accumulator << record.annote.to_s.presence if record.respond_to?(:annote)
}

to_field 'format_main_ssim', literal('Reference')

# raw serialization of BibTeX::Entry
to_field 'bibtex_ts', from_bibtex(:raw)

# formatted BibTeX::Entry in Chicago style as HTML
to_field 'formatted_bibliography_ts', lambda { |record, accumulator, _context|
  html = Bibliography.new(record.to_s).to_html
  doc = Nokogiri::HTML(html)
  li = doc.at_css('ol li')
  reference = li.children.to_html if li.present? # extract just the reference from <li>
  accumulator << reference.to_s
}

# Druids are kept as tags (keywords) in the BibTeX::Entry
to_field 'related_document_id_ssim', lambda { |record, accumulator, _context|
  record.keywords.to_s.split(',').map(&:strip).each do |druid|
    accumulator << druid if druid =~ Exhibits::Application.config.druid_regex
  end
}
