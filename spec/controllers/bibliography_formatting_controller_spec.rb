# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BibliographyFormattingController, type: :controller do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:bibtex) { Pathname('spec/fixtures/bibliography/article.bib') }
  let(:document) { instance_double(SolrDocument, bibtex: bibtex) }

  describe '#show' do
    context 'when input is valid' do
      let(:id) { 'QTWBAWKX' }

      before do
        allow(SolrDocument).to receive(:find).with(id).and_return(document)
      end

      it 'formats the bibliography correctly' do
        get :show, params: { exhibit_id: exhibit.id, id: [id] }
        expect(response.content_type).to eq 'text/html'
        expect(response.body).to include 'Wille, Clara'
      end
    end

    context 'when input is invalid' do
      it 'raises an exception' do
        expect { get :show, params: { exhibit_id: exhibit.id } }.to raise_error(ActionController::ParameterMissing)
      end
    end
  end
end
