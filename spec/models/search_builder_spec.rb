require 'rails_helper'

describe SearchBuilder do
  subject(:search_builder) { described_class.new(scope).with(params) }
  let(:scope) { instance_double CatalogController }
  let(:params) { {} }

  describe '#add_mm_for_boolean_or_queries' do
    let(:solr_parameters) { {}.tap { |h| search_builder.add_mm_for_boolean_or_queries(h) } }

    context 'with a blank query' do
      it 'does not set a mm parameter' do
        expect(solr_parameters).not_to have_key(:mm)
      end
    end

    context 'with a simple query' do
      let(:params) { { q: 'some string' } }
      it 'does not set a mm parameter' do
        expect(solr_parameters).not_to have_key(:mm)
      end
    end

    context 'with a simple query with a lowercase "or"' do
      let(:params) { { q: 'some string or something' } }
      it 'does not set a mm parameter' do
        expect(solr_parameters).not_to have_key(:mm)
      end
    end

    context 'with a simple query with an uppercase "OR"' do
      let(:params) { { q: 'some string OR something' } }
      it 'does not set a mm parameter' do
        expect(solr_parameters[:mm]).to eq 0
      end
    end

    context 'with an advanced boolean query' do
      let(:params) { { q: 'some string OR something AND whatever' } }
      it 'does not set a mm parameter' do
        expect(solr_parameters).not_to have_key(:mm)
      end
    end
  end
end
