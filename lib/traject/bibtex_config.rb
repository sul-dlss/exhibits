# frozen_string_literal: true

require_relative 'bib_reader'

settings do
  provide 'reader_class_name', 'BibReader'
end

to_field 'id', lambda { |record, accumulator, _context|
  accumulator << record.key.gsub('http://zotero.org/groups/1051392/items/', '')
}

to_field 'title_display', lambda { |record, accumulator, _context|
  accumulator << record.title.to_s(filter: :latex)
}

to_field 'title_uniform_search', lambda { |record, accumulator, _context|
  accumulator << record.title.to_s(filter: :latex)
}

to_field 'format_main_ssim', literal('Reference')
