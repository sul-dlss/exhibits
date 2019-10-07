# frozen_string_literal: true

require 'rails_helper'

describe 'viewers/_mirador.html.erb', type: :view do
  let(:document) do
    SolrDocument.new(
      'id' => 'abc123',
      'iiif_manifest_url_ssi' => 'https://purl.stanford.edu/bc853rd3116?manifest',
      'content_metadata_type_ssm' => %w(image)
    )
  end
  let(:current_exhibit) { create(:exhibit) }
  let(:viewer) { Viewer.create(exhibit_id: exhibit.id) }

  before do
    render partial: 'viewers/mirador', locals: { current_exhibit: current_exhibit, document: document }
  end

  it 'has one iframe tag' do
    expect(rendered).to have_selector(:css, 'iframe', count: 1)
  end

  it 'the iframe tag allows fullscreen' do
    iframe = Capybara.string(rendered).find('iframe')

    expect(iframe['allowfullscreen']).to eq 'true'
  end

  context 'when manifest is missing' do
    let(:document) { SolrDocument.new }

    it 'is not viewable' do
      expect(rendered).not_to have_css 'iframe'
    end
  end

  context 'when using default indexed manifest' do
    it do
      expect(rendered).to include CGI.escape('https://purl.stanford.edu/bc853rd3116?manifest')
    end
  end

  context 'when using a custom manifest pattern' do
    before do
      current_exhibit.required_viewer.custom_manifest_pattern = 'https://example.com/{id}'
      current_exhibit.viewer.save
      # Re-render now that the exhibit is updated
      render partial: 'viewers/mirador', locals: { current_exhibit: current_exhibit, document: document }
    end

    it do
      expect(rendered).to include CGI.escape('https://example.com/abc123')
    end
  end

  it 'has the IIIF drag and drop' do
    expect(rendered).to have_css 'a[href="https://library.stanford.edu/project'\
      's/international-image-interoperability-framework/viewers?manifest=https'\
      '%3A%2F%2Fpurl.stanford.edu%2Fbc853rd3116%3Fmanifest"]'
  end
end
