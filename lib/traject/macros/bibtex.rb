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

    ##
    # Traject macro for converting BibTeX fields into Solr fields
    #
    # @param [Symbol] `key` the BibTeX field name
    def from_bibtex(key) # rubocop: disable Metrics/AbcSize, Metrics/CyclomaticComplexity
      # Note that `record` is a BibTeX::Entry object
      lambda do |record, accumulator, _context|
        case key # BibTeX fields don't all follow the same rules, so handle them here
        when :id # we need to transform the key for a good id
          accumulator << record.key.to_s.gsub(%r{http:\/\/zotero.org\/groups\/\d*\/items\/}, '')
        when :key # `key` is always available (yet `provides?(:key)` is false)
          accumulator << record.key.to_s
        when :type # conflates with BibTeX notion of type (`record.type`) rather than field "type"
          accumulator << record.fields[:type].to_s.presence if record.fields.include?(:type)
        when :ref_type # use record.type to get BibTeX type
          accumulator << BIBTEX_ZOTERO_MAPPING[record.type] if BIBTEX_ZOTERO_MAPPING.include?(record.type)
        when :year # built-in method in BibTeX::Entry
          accumulator << record.year
        when :raw # serialization into BibTeX format
          accumulator << record.to_s
        else # use the dynamically constructed BibTeX method to fetch the field rather than fetch/get
          accumulator << record.send(key).to_s.presence if record.respond_to?(key)
        end
      end
    end
  end
end
