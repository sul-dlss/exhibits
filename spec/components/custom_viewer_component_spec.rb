# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CustomViewerComponent, type: :component do
  describe 'rendering' do
    let(:component) { described_class.new(presenter:) }
    let(:presenter) { instance_double(Blacklight::ShowPresenter, document:) }
    let(:exhibit) { create(:exhibit) }
    let(:viewer_type) { 'mirador3' }
    let(:request_url) { "/#{exhibit.slug}/catalog/#{document.id}" }
    let(:manifest_url) { 'http://example.com/iiif/manifest' }

    before do
      exhibit.required_viewer.update(viewer_type:)
      with_controller_class CatalogController do
        allow(vc_test_controller).to receive_messages(
          current_exhibit: exhibit,
          current_search_session: instance_double(Search, query_params: {}),
          feature_flags: FeatureFlags.for(exhibit)
        )
        with_request_url(request_url) { render_inline(component) }
      end
    end

    context 'with external_iiif resource' do
      let(:document) do
        SolrDocument.new(id: 'abc', iiif_manifest_url_ssi: manifest_url,
                         spotlight_resource_type_ssim: ['spotlight/resources/iiif_harvesters'])
      end

      it 'renders the component' do
        expect(page).to have_css "iframe[src='https://embed.stanford.edu/iiif?#{{ url: manifest_url }.to_query}']"
      end
    end

    context 'with a purl resource' do
      let(:document) do
        SolrDocument.new(id: 'abc123', druid: 'abc123', url_fulltext: ['https://purl.stanford.edu/abc123'],
                         iiif_manifest_url_ssi: manifest_url, content_metadata_type_ssm: ['image'],
                         iiif_canvas_id_ssim: ['canvas-1'])
      end

      context 'in an exhibit configured to use mirador' do
        it 'renders the mirador viewer and a purl link' do
          expect(page).to have_css 'iframe[src*="enable_comparison=true"]'
          expect(page).to have_no_css '.oembed-widget'
          expect(page).to have_link 'purl.stanford.edu/abc123', href: 'https://purl.stanford.edu/abc123'
        end
      end

      context 'in an exhibit configured to use sul-embed' do
        let(:viewer_type) { 'sul-embed' }

        it 'renders the oembed viewer and a purl link' do
          expect(page).to have_css '.oembed-widget [data-embed-url*="url=https%3A%2F%2Fpurl.stanford.edu%2Fabc123"]'
          expect(page).to have_link 'purl.stanford.edu/abc123', href: 'https://purl.stanford.edu/abc123'
        end
      end

      context 'outside of the exhibit catalog (e.g. a feature page)' do
        let(:request_url) { "/#{exhibit.slug}/feature/a-page" }

        it 'renders the oembed viewer even if the exhibit is configured to use mirador' do
          expect(page).to have_css '.oembed-widget'
          expect(page).to have_no_css 'iframe'
        end
      end

      context 'in an exhibit that is configured (via feature flag) to point to UAT' do
        let(:exhibit) { create(:exhibit, slug: 'test-flag-exhibit-slug') }
        let(:viewer_type) { 'sul-embed' }

        it 'uses the UAT purl' do
          expect(page).to have_css '.oembed-widget ' \
                                   '[data-embed-url*="url=https%3A%2F%2Fsul-purl-uat.stanford.edu%2Fabc123"]'
          expect(page).to have_link 'sul-purl-uat.stanford.edu/abc123'
        end
      end
    end
  end

  describe CustomViewerComponent::SirTrevorBlock do
    it 'returns the selected canvas and initial viewer config' do
      block = described_class.new(item: [{ 'iiif_canvas_id' => 'canvas-4', 'iiif_initial_viewer_config' => '{}' }])
      expect(block.canvas_id).to eq 'canvas-4'
      expect(block.initial_viewer_config).to eq '{}'
    end

    it 'ignores an undefined initial viewer config' do
      block = described_class.new(item: [{ 'iiif_initial_viewer_config' => 'undefined' }])
      expect(block.initial_viewer_config).to be_nil
    end

    it 'defaults to nil when there is no item' do
      block = described_class.new(item: nil)
      expect(block.canvas_id).to be_nil
      expect(block.initial_viewer_config).to be_nil
    end
  end
end
