# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchAcrossThumbnailPresenter do
  subject(:presenter) { described_class.new(document, view_context, config) }

  let(:view_context) { view }
  let(:config) { Blacklight::Configuration.new.view_config(:index) }
  let(:document) { SolrDocument.new xyz: img_url }
  let(:img_url) { 'http://example.com/some.jpg' }
  let(:img) { '<img src="image.jpg">' }

  before do
    config.thumbnail_field = :xyz
  end

  it 'renders thumbnails that link to documents' do
    allow(view_context).to receive(:image_tag).with(img_url, {}).and_return(img)
    allow(view_context).to receive(:link_to_document).with(document, img, {})
                                                     .and_return('link-with-img')
    expect(presenter.thumbnail_tag).to eq 'link-with-img'
  end

  context 'for documents belonging to multiple exhibits' do
    let(:document) { SolrDocument.new "#{SolrDocument.exhibit_slug_field}": %w(a b), xyz: img_url }

    it 'suppresses the default linking behavior' do
      allow(view_context).to receive(:image_tag).with(img_url, {}).and_return(img)
      expect(presenter.thumbnail_tag).to eq img
    end
  end
end
