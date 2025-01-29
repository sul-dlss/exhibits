# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmbeddedMiradorComponent, type: :component do
  let(:component) { described_class.new(document:) }
  let(:document) { SolrDocument.new(id: 'abc', iiif_manifest_url_ssi: manifest_url) }
  let(:manifest_url) { 'http://example.com/iiif/manifest' }

  before do
    render_inline(component)
  end

  it 'renders an iframe' do
    expect(page).to have_css "iframe[src='https://embed.stanford.edu/iiif?#{{ url: manifest_url }.to_query}']"
  end

  context 'with a local IIIF manifest' do
    let(:manifest_url) { '/iiif/manifest' }

    it 'uses the full url to the manifest' do
      expected_url = 'http://test.host/iiif/manifest'

      expect(page).to have_css "iframe[src='https://embed.stanford.edu/iiif?#{{ url: expected_url }.to_query}']"
    end
  end
end
