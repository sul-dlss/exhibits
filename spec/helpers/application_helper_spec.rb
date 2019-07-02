# frozen_string_literal: true

require 'rails_helper'

describe ApplicationHelper, type: :helper do
  describe '#collection_title' do
    it 'unmangles the collection title from the compound field' do
      expect(helper.collection_title('foo-|-bar')).to eq 'bar'
    end
  end

  describe '#collection_title_for_index_field' do
    it 'unmangles the collection title from the compound field' do
      expect(helper.document_collection_title(value: 'foo-|-bar')).to eq 'bar'
    end

    it 'handles multivalued fields' do
      expect(helper.document_collection_title(value: ['foo-|-bar', 'baz-|-bop'])).to eq 'bar and bop'
    end
  end

  describe '#custom_render_oembed_tag_async' do
    let(:document) { SolrDocument.new(url_fulltext: ['http://example.com/stuff'], druid: 'abc123') }

    context 'normal embed' do
      it 'renders a div with embed attribute and canvas index param' do
        expect(helper).to receive_messages(
          blacklight_config: CatalogController.blacklight_config,
          current_search_session: instance_double('Blacklight::SearchSession', query_params: {}),
          feature_flags: FeatureFlags.for(create(:exhibit))
        )
        rendered = helper.custom_render_oembed_tag_async(document, 3)
        expect(rendered).to have_css '[data-embed-url="http://test.host/oembed/e'\
          'mbed?canvas_id=3&url=http%3A%2F%2Fexample.com%2Fstuff"]'
      end

      it 'uses the q from the current_search_session to populate the suggested_search param' do
        expect(helper).to receive_messages(
          blacklight_config: CatalogController.blacklight_config,
          current_search_session: instance_double('Blacklight::SearchSession', query_params: { q: 'The Query' }),
          feature_flags: FeatureFlags.for(create(:exhibit))
        )
        rendered = helper.custom_render_oembed_tag_async(document, 3)
        expect(rendered).to match(/&amp;suggested_search=The\+Query&amp;/)
      end
    end

    context 'an exhibit that is configured (via feature flag) to point to UAT' do
      it 'renders a div with the correct embed end-point in the data attribute' do
        expect(helper).to receive_messages(
          current_search_session: instance_double('Blacklight::SearchSession', query_params: {}),
          feature_flags: FeatureFlags.for(create(:exhibit, slug: 'test-flag-exhibit-slug'))
        )
        rendered = helper.custom_render_oembed_tag_async(document, 3)
        expect(rendered).to have_css '[data-embed-url="http://test.host/oembed/e'\
          'mbed?canvas_id=3&url=https%3A%2F%2Fsul-purl-uat.stanford.edu%2Fabc123"]'
      end
    end
  end

  describe '#choose_canvas_id' do
    context 'with a valid SirTrevor Block' do
      let(:canvas_index) { 4 }
      let(:st_block) do
        instance_double(
          'SirTrevorRails::Blocks::SolrDocumentsEmbedBlock',
          items: [{ 'iiif_canvas_id' => "http://example.com/ab123cd4567_#{canvas_index}" }]
        )
      end

      it 'returns the selected iiif_canvas_id from the block' do
        expect(helper.choose_canvas_id(st_block)).to eq "http://example.com/ab123cd4567_#{canvas_index}"
      end
    end

    context 'with SirTrevorBlock that is missing things' do
      let(:st_block) do
        instance_double('SirTrevorRails::Blocks::SolrDocumentsEmbedBlock')
      end

      it 'defaults to nil' do
        expect(helper.choose_canvas_id(st_block)).to eq nil
      end
    end
  end
end
