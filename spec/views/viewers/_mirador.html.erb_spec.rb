require 'rails_helper'

describe 'viewers/_mirador.html.erb', type: :view do
  let(:document) { { 'iiif_manifest_url_ssi' => 'https://purl.stanford.edu/bc853rd3116?manifest' } }
  before do
    render partial: 'viewers/mirador', locals: { document: document }
  end

  it 'has one script tag which contains the correct data' do
    expect(rendered).to have_content(document['iiif_manifest_url_ssi'])
    expect(rendered).to have_selector(:css, 'script', visible: false, count: 1)
  end
end
