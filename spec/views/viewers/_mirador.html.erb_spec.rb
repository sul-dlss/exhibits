require 'rails_helper'

describe 'viewers/_mirador.html.erb', type: :view do
  let(:document) do
    SolrDocument.new('iiif_manifest_url_ssi' => 'https://purl.stanford.edu/bc853rd3116?manifest')
  end

  before do
    render partial: 'viewers/mirador', locals: { document: document }
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
end
