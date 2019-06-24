# frozen_string_literal: true

require_relative 'extraction'

module Macros
  # BibTeX extraction macros
  module BibTeX
    # formatted BibTeX::Entry in Chicago style as HTML
    def extract_bibtex_formatted_bibliography
      lambda do |record, accumulator, _context|
        html = Bibliography.new(record.to_s).to_html
        doc = Nokogiri::HTML(html)
        li = doc.at_css('ol li')
        reference = li.children.to_html if li.present? # extract just the reference from <li>
        accumulator << reference.to_s
      end
    end

    def extract_bibtex(method, options = {})
      lambda do |record, accumulator, _context|
        result = record.public_send(method)
        result = Macros::Extraction.apply_extraction_options(result, options)
        Array.wrap(result).compact.each do |value|
          accumulator << value.to_s
        end
      end
    end

    ##
    # Traject macro for converting BibTeX fields into Solr fields
    #
    # @param [Symbol] `key` the BibTeX field name
    def extract_bibtex_field(key, options = {})
      # Note that `record` is a BibTeX::Entry object
      lambda do |record, accumulator, _context|
        if record.fields.key? key.to_sym
          result = record.fields[key.to_sym].to_s.presence
          result = Macros::Extraction.apply_extraction_options(result, options)
          Array.wrap(result).compact.each do |value|
            accumulator << value.to_s
          end
        end
      end
    end
  end
end
