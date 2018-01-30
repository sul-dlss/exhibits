# frozen_string_literal: true

require 'rails_helper'

describe CatalogController do
  describe '#full_text_highlight_exists_in_response?' do
    context 'when there is no solr response' do
      it 'does not throw an error (returns false)' do
        expect(
          described_class.full_text_highlight_exists_in_response?(
            instance_double('Context'),
            instance_double('Config'),
            SolrDocument.new(id: 'abc123')
          )
        ).to be false
      end
    end
  end
end
