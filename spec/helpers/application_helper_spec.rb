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
    context 'when no custom viewer pattern is set' do
      let(:document) { SolrDocument.new(url_fulltext: ['http://example.com/stuff']) }

      it 'renders a div with embed attribute and canvas index param' do
        expect(helper).to receive_messages(
          blacklight_config: CatalogController.blacklight_config,
          current_exhibit: create(:exhibit)
        )
        rendered = helper.custom_render_oembed_tag_async(document, 3)
        expect(rendered).to have_css '[data-embed-url="http://test.host/oembed/e'\
          'mbed?canvas_index=3&url=http%3A%2F%2Fexample.com%2Fstuff"]'
      end
    end

    context 'when a custom viewer pattern is provided' do
      let(:document) do
        SolrDocument.new(
          id: 'abc123',
          url_fulltext: ['http://example.com/stuff'],
          content_metadata_type_ssm: ['image'],
          iiif_manifest_url_ssi: 'htts://example.com/info.json'
        )
      end

      it 'uses a custom manifest pattern if set' do
        expect(helper).to receive_messages(
          current_exhibit: create(
            :exhibit,
            viewer: create(:viewer, custom_manifest_pattern: 'https://embed-example.com/{id}')
          )
        )
        rendered = helper.custom_render_oembed_tag_async(document, 1)

        expect(rendered).to have_css '[data-embed-url="http://test.host/oembed/e'\
          'mbed?canvas_index=1&url=https%3A%2F%2Fembed-example.com%2Fabc123"]'
      end
    end
  end

  describe '#choose_canvas_index' do
    context 'with a valid SirTrevor Block' do
      let(:canvas_index) { 4 }
      let(:st_block) do
        instance_double(
          'SirTrevorRails::Blocks::SolrDocumentsEmbedBlock',
          items: [{ 'iiif_canvas_id' => "http://example.com/ab123cd4567_#{canvas_index}" }]
        )
      end

      it 'returns a zero based index' do
        expect(helper.choose_canvas_index(st_block)).to eq 3
      end

      # rubocop:disable RSpec/NestedGroups
      context 'when index is zero' do
        let(:canvas_index) { 0 }

        it 'does not return a negative number' do
          expect(helper.choose_canvas_index(st_block)).to eq 0
        end
      end
      # rubocop:enable RSpec/NestedGroups
    end
    context 'with SirTrevorBlock that is missing things' do
      let(:st_block) do
        instance_double('SirTrevorRails::Blocks::SolrDocumentsEmbedBlock')
      end

      it 'defaults a return to zero' do
        expect(helper.choose_canvas_index(st_block)).to eq 0
      end
    end
  end
end
