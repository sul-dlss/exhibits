# frozen_string_literal: true

require_relative 'bib_reader'
require_relative 'bib_json_resource_writer'
# require_relative 'macros/json'

# extend Macros::JSON

settings do
  provide 'reader_class_name', 'BibReader'
  provide 'writer_class_name', 'BibJsonResourceWriter'
end

to_field 'id', lambda { |record, accumulator, _context|
  accumulator << record.key
}

to_field 'title_245a_search', lambda { |record, accumulator, _context|
  accumulator << record.title.to_s(filter: :latex)
}

to_field 'title_245_search', lambda { |record, accumulator, _context|
  accumulator << record.title.to_s(filter: :latex)
}

to_field 'title_sort', lambda { |record, accumulator, _context|
  accumulator << record.title.to_s(filter: :latex)
}

to_field 'title_display', lambda { |record, accumulator, _context|
  accumulator << record.title.to_s(filter: :latex)
}

to_field 'title_full_display', lambda { |record, accumulator, _context|
  accumulator << record.title.to_s(filter: :latex)
}
