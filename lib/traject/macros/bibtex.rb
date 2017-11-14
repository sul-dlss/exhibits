# frozen_string_literal: true

require_relative 'extraction'

module Macros
  # BibTeX extraction macros
  module BibTeX
    BIBTEX_ZOTERO_MAPPING = {
      phdthesis: 'Thesis',
      incollection: 'Book section',
      article: 'Journal article',
      book: 'Book',
      misc: 'Document'
    }.freeze

    # we need to transform the key for a good id
    def extract_bibtex_id
      lambda do |record, accumulator, _context|
        bibtex_id = record.key.to_s
        accumulator << bibtex_id.gsub(%r{http:\/\/zotero.org\/groups\/\d*\/items\/}, '')
      end
    end

    # `key` is always available (yet `provides?(:key)` is false)
    def extract_bibtex_key
      lambda do |record, accumulator, _context|
        accumulator << record.key.to_s
      end
    end

    # raw serialization of BibTeX::Entry
    def extract_bibtex_raw
      lambda do |record, accumulator, _context|
        accumulator << record.to_s
      end
    end

    def extract_bibtex_publication
      lambda do |record, accumulator, _context|
        %i(journal publisher).each do |key|
          accumulator << record.send(key).to_s.presence if record.respond_to?(key)
        end
      end
    end

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

    # Druids are kept as tags (keywords) in the BibTeX::Entry
    def extract_bibtex_related_document_ids
      extract_bibtex_field(:keywords,
                           split: ',',
                           trim: true,
                           match: Exhibits::Application.config.druid_regex)
    end

    ##
    # Traject macro for converting BibTeX fields into Solr fields
    #
    # @param [Symbol] `key` the BibTeX field name
    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
    def extract_bibtex_field(key, options = {})
      # Note that `record` is a BibTeX::Entry object
      lambda do |record, accumulator, _context|
        case key.to_sym # BibTeX fields don't all follow the same rules, so handle them here
        when :type # conflates with BibTeX notion of type (`record.type`) rather than field "type"
          accumulator << record.fields[:type].to_s.presence if record.fields.include?(:type)
        when :ref_type # use record.type to get BibTeX type
          accumulator << BIBTEX_ZOTERO_MAPPING[record.type] if BIBTEX_ZOTERO_MAPPING.include?(record.type)
        when :year # built-in method in BibTeX::Entry
          accumulator << record.year
        else # use the dynamically constructed BibTeX method to fetch the field rather than fetch/get
          if record.respond_to?(key.to_sym)
            result = record.send(key.to_sym).to_s.presence
            result = Macros::Extraction.apply_extraction_options(result, options)
            Array.wrap(result).compact.each do |value|
              accumulator << value
            end
          end
        end
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity
  end
end
