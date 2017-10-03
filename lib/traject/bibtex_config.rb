# frozen_string_literal: true

require_relative 'bib_reader'
require 'bibliography'
require 'active_support/core_ext/object/blank'

settings do
  provide 'reader_class_name', 'BibReader'
end

each_record do |record, context|
  context.skip!("Skipping #{record.key} no title") if record.title.blank?
  context.skip!("Skipping #{record.key} no keywords") unless record.respond_to?(:keywords)
  context.clipboard[:title] = record.title.to_s.presence
end

to_field 'id', lambda { |record, accumulator, _context|
  accumulator << record.key.gsub('http://zotero.org/groups/1051392/items/', '')
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

to_field 'author_person_full_display', lambda { |record, accumulator, _context|
  accumulator << record.author.to_s.presence
}

to_field 'pub_display', lambda { |record, accumulator, _context|
  accumulator << record.journal.to_s.presence if record.respond_to?(:journal)
}

to_field 'volume_ssm', lambda { |record, accumulator, _context|
  accumulator << record.volume.to_s.presence if record.respond_to?(:volume)
}

to_field 'pages_ssm', lambda { |record, accumulator, _context|
  accumulator << record.pages.to_s.presence if record.respond_to?(:pages)
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
