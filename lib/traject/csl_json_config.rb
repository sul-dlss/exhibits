# frozen_string_literal: true

require_relative 'json_reader'
require_relative 'bib_json_resource_writer'
require_relative 'macros/json'

extend Macros::JSON

settings do
  provide 'reader_class_name', 'JsonReader'
  provide 'writer_class_name', 'BibJsonResourceWriter'
end

to_field 'id', extract_json('$.id', first: true)
to_field 'title_245a_search', extract_json('$.title')
to_field 'title_245_search', extract_json('$.title')
to_field 'title_sort', extract_json('$.title')
to_field 'title_display', extract_json('$.title')
to_field 'title_full_display', extract_json('$.title')
