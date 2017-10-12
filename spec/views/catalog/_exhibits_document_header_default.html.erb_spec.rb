require 'rails_helper'

describe 'catalog/_exhibits_document_header_default', type: :view do
  let(:document) { SolrDocument.new }
  let(:exhibit) { create(:exhibit) }

  before do
    expect(view).to receive_messages(
      current_exhibit: exhibit,
      document: document,
      document_counter: 0,
      render_document_partial: -> {}
    )

    render
  end

  describe 'IIIF Drag-n-Drop Icon' do
    context 'when the document has a manifest' do
      let(:document) { SolrDocument.new(iiif_manifest_url_ssi: 'https://purl.stanford.edu/bc853rd3116/iiif/manifest') }

      it 'rendres the icon' do
        expect(rendered).to have_css('a.iiif-dnd')
      end
    end

    context 'when the document does not have a manifest' do
      it 'does not render the icon' do
        expect(rendered).not_to have_css('a.iiif-dnd')
      end
    end
  end
end
