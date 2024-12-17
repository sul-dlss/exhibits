# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmbeddedMiradorComponent, type: :component do
  let(:component) { described_class.new(document:, block:) }
  let(:document) { SolrDocument.new(id: 'abc', iiif_manifest_url_ssi: manifest_url) }
  let(:sir_trevor_block) { Struct.new(:maxheight, :item) }
  let(:block) { sir_trevor_block.new(item: nil) }
  let(:manifest_url) { 'http://example.com/iiif/manifest' }

  before do
    render_inline(component)
  end

  it 'renders an iframe' do
    expect(page).to have_css "iframe[src='https://embed.stanford.edu/iiif?#{{ url: manifest_url,
                                                                              iiif_initial_viewer_config: '',
                                                                              canvas_id: '' }.to_query}']"
  end

  context 'with a local IIIF manifest' do
    let(:manifest_url) { '/iiif/manifest' }

    it 'uses the full url to the manifest' do
      expected_url = 'http://test.host/iiif/manifest'

      expect(page).to have_css "iframe[src='https://embed.stanford.edu/iiif?#{{ url: expected_url,
                                                                                iiif_initial_viewer_config: '',
                                                                                canvas_id: '' }.to_query}']"
    end
  end
end
