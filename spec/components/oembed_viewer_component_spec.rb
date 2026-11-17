# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OembedViewerComponent, type: :component do
  let(:component) { described_class.new(url: 'http://example.com/stuff', block:) }
  let(:block) { nil }
  let(:query_params) { {} }
  let(:request_params) { {} }

  before do
    with_controller_class CatalogController do
      allow(vc_test_controller).to receive(:current_search_session)
        .and_return(instance_double(Search, query_params:))
      with_request_url "/catalog/abc123?#{request_params.to_query}" do
        render_inline(component)
      end
    end
  end

  it 'renders a div with the embed url' do
    expect(page).to have_css '.oembed-widget ' \
                             '[data-embed-url="/oembed/embed?maxheight=600&url=http%3A%2F%2Fexample.com%2Fstuff"]'
  end

  context 'with a q in the current search session' do
    let(:query_params) { { q: 'The Query' } }

    it 'populates the suggested_search param' do
      expect(page).to have_css '[data-embed-url*="suggested_search=The+Query"]'
    end
  end

  context 'with a SirTrevor block' do
    let(:block) do
      CustomViewerComponent::SirTrevorBlock.new(
        maxheight: 300,
        item: [{ 'iiif_canvas_id' => 'http://example.com/canvas_4', 'iiif_initial_viewer_config' => 'undefined' }]
      )
    end

    it 'passes the maxheight and canvas id from the block' do
      expect(page).to have_css '[data-embed-url="/oembed/embed?canvas_id=http%3A%2F%2Fexample.com%2Fcanvas_4' \
                               '&maxheight=300&url=http%3A%2F%2Fexample.com%2Fstuff"]'
    end
  end

  context 'with canvas_id and search request params' do
    let(:request_params) { { canvas_id: '3', search: 'foo' } }

    it 'passes them through' do
      expect(page).to have_css '[data-embed-url="/oembed/embed?canvas_id=3&maxheight=600&search=foo' \
                               '&url=http%3A%2F%2Fexample.com%2Fstuff"]'
    end
  end
end
