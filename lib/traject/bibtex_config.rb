# frozen_string_literal: true

require_relative 'bib_reader'
require 'bibliography'
require 'active_support/core_ext/object/blank'

settings do
  provide 'reader_class_name', 'BibReader'
end

BIBTEX_ZOTERO_MAPPING = {
  phdthesis: 'Thesis',
  incollection: 'Book section',
  article: 'Journal article',
  book: 'Book',
  misc: 'Document'
}.freeze

each_record do |record, context|
  context.skip!("Skipping #{record.key} no title") if record.title.blank?
  context.skip!("Skipping #{record.key} no keywords") unless record.respond_to?(:keywords)
  context.clipboard[:title] = record.title.to_s.presence
  context.clipboard[:author] = record.author.to_s.presence
end

to_field 'id', lambda { |record, accumulator, _context|
  accumulator << record.key.gsub(%r{http:\/\/zotero.org\/groups\/\d*\/items\/}, '')
}

to_field 'bibtex_key_ss', lambda { |record, accumulator, _context|
  accumulator << record.key
}

to_field 'ref_type_ssm', lambda { |record, accumulator, _context|
  accumulator << BIBTEX_ZOTERO_MAPPING[record.type] if BIBTEX_ZOTERO_MAPPING.include?(record.type)
}

to_field 'title_display', lambda { |_record, accumulator, context|
  accumulator << context.clipboard[:title]
}

to_field 'title_full_display', lambda { |_record, accumulator, context|
  accumulator << context.clipboard[:title]
}

to_field 'title_uniform_search', lambda { |_record, accumulator, context|
  accumulator << context.clipboard[:title]
}

to_field 'title_sort', lambda { |_record, accumulator, context|
  accumulator << context.clipboard[:title]
}

to_field 'author_person_full_display', lambda { |_record, accumulator, context|
  accumulator << context.clipboard[:author]
}

to_field 'author_sort', lambda { |_record, accumulator, context|
  accumulator << context.clipboard[:author]
}

to_field 'pub_year_isi', lambda { |record, accumulator, _context|
  accumulator << record.year.to_i.presence if record.respond_to?(:year)
}

to_field 'editor_ssim', lambda { |record, accumulator, _context|
  accumulator << record.editor.to_s.presence if record.respond_to?(:editor)
}

to_field 'book_title_ssim', lambda { |record, accumulator, _context|
  accumulator << record.booktitle.to_s.presence if record.respond_to?(:booktitle)
}

to_field 'pub_display', lambda { |record, accumulator, _context|
  accumulator << record.journal.to_s.presence if record.respond_to?(:journal)
  accumulator << record.publisher.to_s.presence if record.respond_to?(:publisher)
}

to_field 'pub_year_w_approx_isi', lambda { |record, accumulator, _context|
  accumulator << record.year.to_s.presence if record.respond_to?(:year)
}

to_field 'location_ssi', lambda { |record, accumulator, _context|
  accumulator << record.address.to_s.presence if record.respond_to?(:address)
}

to_field 'university_ssim', lambda { |record, accumulator, _context|
  accumulator << record.school.to_s.presence if record.respond_to?(:school)
}

to_field 'edition_ssm', lambda { |record, accumulator, _context|
  accumulator << record.edition.to_s.presence if record.respond_to?(:edition)
}

to_field 'series_ssi', lambda { |record, accumulator, _context|
  accumulator << record.series.to_s.presence if record.respond_to?(:series)
}

to_field 'thesis_type_ssm', lambda { |record, accumulator, _context|
  accumulator << record.fields[:type].to_s.presence if record.fields.include?(:type)
}

to_field 'volume_ssm', lambda { |record, accumulator, _context|
  accumulator << record.volume.to_s.presence if record.respond_to?(:volume)
}

to_field 'issue_ssm', lambda { |record, accumulator, _context|
  accumulator << record.issue.to_s.presence if record.respond_to?(:issue)
}

to_field 'pages_ssm', lambda { |record, accumulator, _context|
  accumulator << record.pages.to_s.presence if record.respond_to?(:pages)
}

to_field 'doi_ssim', lambda { |record, accumulator, _context|
  accumulator << record.doi.to_s.presence if record.respond_to?(:doi)
}

to_field 'format_main_ssim', literal('Reference')

# raw serialization of BibTeX::Entry
to_field 'bibtex_ts', lambda { |record, accumulator, _context|
  accumulator << record.to_s
}

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
