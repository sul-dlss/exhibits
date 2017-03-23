require 'rails_helper'

describe 'catalog/_bibliography_default.html.erb', type: :view do
  let(:exhibit) { instance_double(Spotlight::Exhibit, bibliography_service: bibliography_service) }
  before do
    render partial: 'catalog/bibliography_default', locals: { document: document, current_exhibit: exhibit }
  end
  context 'with a populated bibliography' do
    let(:document) do
      SolrDocument.new(
        Settings.zotero_api.solr_document_field => ['<ul><li><div class="csl-bib-body"></li></ul>']
      )
    end
    context 'with a bibliography service' do
      let(:bibliography_service) { create(:bibliography_service, header: 'Bib Header') }
      it do
        expect(rendered).to have_css 'h3', text: 'Bib Header'
        expect(rendered).to have_css 'ul li .csl-bib-body'
      end
    end
    context 'without a bibliography service' do
      let(:bibliography_service) { nil }
      it { expect(rendered).to eq '' }
    end
  end
  context 'without a populated bibliography' do
    let(:document) { SolrDocument.new }
    let(:bibliography_service) { create(:bibliography_service, header: 'Bib Header') }
    it do
      expect(rendered).to eq ''
    end
  end
end
