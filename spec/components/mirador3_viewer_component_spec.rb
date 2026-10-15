# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mirador3ViewerComponent, type: :component do
  let(:component) { described_class.new(document:, exhibit:) }
  let(:exhibit) { create(:exhibit) }
  let(:document) do
    SolrDocument.new(id: 'abc', iiif_manifest_url_ssi: manifest_url, content_metadata_type_ssm: ['image'],
                     iiif_canvas_id_ssim: ['canvas-1'], title_display: 'A title')
  end
  let(:manifest_url) { 'http://example.com/iiif/manifest' }

  before do
    render_inline(component)
  end

  it 'renders an iframe with an accessible title' do
    expected_query = { url: manifest_url, enable_comparison: true, canvas_id: 'canvas-1' }.to_query
    expect(page).to have_css "iframe[src='https://embed.stanford.edu/iiif?#{expected_query}']" \
                             "[title='Mirador viewer: A title']"
  end

  context 'with a custom manifest pattern' do
    let(:exhibit) do
      create(:exhibit).tap do |exhibit|
        exhibit.required_viewer.update(custom_manifest_pattern: 'https://example.com/{id}/manifest')
      end
    end

    it 'uses the exhibit specific manifest' do
      expect(page).to have_css "iframe[src*='#{CGI.escape('https://example.com/abc/manifest')}']"
    end
  end

  context 'without a manifest' do
    let(:manifest_url) { nil }

    it 'renders nothing' do
      expect(page).to have_no_css 'iframe'
    end
  end
end
