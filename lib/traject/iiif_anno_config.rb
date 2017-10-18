# frozen_string_literal: true

require_relative 'iiif_annolist_reader'
require_relative 'macros/extraction'
require_relative 'macros/json'
require_relative 'macros/iiif'

extend Macros::IIIF
extend Macros::JSON

settings do
  provide 'reader_class_name', 'IIIFAnnolistReader'
end

to_field 'id', extract_json('$.@id')
to_field 'resource_id', extract_json('$.resource/@id')
to_field 'motivation', extract_json('$.motivation')
