# frozen_string_literal: true

require 'rails_helper'

describe CatalogController do
  describe '#document_has_full_text_and_search_is_query?' do
    it 'is true when a query term is passed and the document has full text' do
      expect(
        described_class.document_has_full_text_and_search_is_query?(
          instance_double('Context', params: { q: 'Search Term' }),
          instance_double('Config'),
          SolrDocument.new(full_text_tesimv: ['Some text'])
        )
      ).to be true
    end

    it 'is false if no query was passed' do
      expect(
        described_class.document_has_full_text_and_search_is_query?(
          instance_double('Context', params: { f: { format_facet: ['Book'] } }),
          instance_double('Config'),
          SolrDocument.new(full_text_tesimv: ['Some text'])
        )
      ).to be false
    end

    it 'is false when a query term is passed but the document has no full text' do
      expect(
        described_class.document_has_full_text_and_search_is_query?(
          instance_double('Context', params: { q: 'Search Term' }),
          instance_double('Config'),
          SolrDocument.new(id: 'abc123')
        )
      ).to be false
    end
  end
end
