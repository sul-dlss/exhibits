# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IiifDragAndDropComponent, type: :component do
  let(:document) { SolrDocument.new(id: 'abc', title_display: 'A title') }
  let(:manifest) { 'https://purl.stanford.edu/abc/iiif/manifest' }
  let(:link_url) { "https://library.stanford.edu/iiif?#{{ manifest: }.to_query}" }

  context 'with a manifest' do
    before do
      render_inline(described_class.new(manifest:, document:))
    end

    it 'links to the IIIF drag-n-drop url for the manifest' do
      expect(page).to have_link(href: link_url, class: %w(iiif-dnd float-end))
    end

    it 'has the expected link attributes' do
      expect(page).to have_css(
        "a.iiif-dnd[data-turbolinks='false'][draggable='true'][aria-label='IIIF Drag-n-drop: A title']"
      )
    end

    it 'renders the IIIF drag-n-drop image' do
      expect(page).to have_css(
        "a.iiif-dnd img.border-0[src*='iiif-drag-n-drop'][width='30'][alt=''][draggable='false']"
      )
    end
  end

  context 'with a custom width' do
    it 'sets the image width' do
      render_inline(described_class.new(manifest:, document:, width: '50'))

      expect(page).to have_css("a.iiif-dnd img[width='50']")
    end
  end

  context 'without a manifest' do
    it 'renders nothing' do
      render_inline(described_class.new(manifest: nil, document:))

      expect(page).to have_no_css('a.iiif-dnd')
    end
  end
end
