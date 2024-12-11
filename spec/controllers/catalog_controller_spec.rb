# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CatalogController do
  describe '#document_has_full_text_and_search_is_query?' do
    it 'is true when a query term is passed and the document has full text' do
      subject.params[:q] = 'Search Term'
      expect(
        described_class.document_has_full_text_and_search_is_query?(
          subject,
          instance_double('Config'),
          instance_double(SolrDocument, full_text?: true)
        )
      ).to be true
    end

    it 'is false if no query was passed' do
      subject.params[:f] = { format_facet: ['Book'] }
      expect(
        described_class.document_has_full_text_and_search_is_query?(
          subject,
          instance_double('Config'),
          instance_double(SolrDocument, full_text?: true)
        )
      ).to be false
    end

    it 'is false when a query term is passed but the document has no full text' do
      subject.params[:q] = 'Search Term'

      expect(
        described_class.document_has_full_text_and_search_is_query?(
          subject,
          instance_double('Config'),
          instance_double(SolrDocument, full_text?: false)
        )
      ).to be false
    end
  end
end
