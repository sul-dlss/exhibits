# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchAcrossController, type: :controller do
  describe 'GET index' do
    context 'with a grouped response' do
      before do
        get :index, params: { q: 'some-query', group: true, sort: 'count' }
      end

      it 'hides the per page widget' do
        expect(controller.blacklight_config.index.collection_actions).not_to include(:per_page_widget)
      end

      it 'adds stub sort fields' do
        expect(controller.blacklight_config.sort_fields.length).to eq 2
        expect(controller.blacklight_config.sort_fields.keys).to eq %w(index count)
        expect(controller.blacklight_config.sort_fields.values.map(&:sort)).to eq ['', '']
      end

      it 'sorts the exhibits by count' do
        expect(controller.blacklight_config.facet_fields[SolrDocument.exhibit_slug_field].sort).to eq 'count'
      end
    end
  end

  describe '#render_grouped_response?' do
    it 'is false' do
      expect(controller).not_to be_render_grouped_response
    end

    context 'with the group param set' do
      before do
        controller.params[:group] = true
      end

      it 'is true' do
        expect(controller.render_grouped_response?).to eq true
      end
    end
  end

  describe '#url_for_document' do
    let(:document) do
      SolrDocument.new(id: 1, "#{SolrDocument.exhibit_slug_field}": ['a'])
    end
    let(:multi_exhibit_document) do
      SolrDocument.new(id: 2, "#{SolrDocument.exhibit_slug_field}": %w(a b))
    end

    it 'links to the document in the context of the exhibit' do
      expected = controller.spotlight.exhibit_solr_document_path(exhibit_id: 'a', id: 1)
      expect(controller.url_for_document(document)).to eq expected
    end

    it 'suppresses links for multi-exhibit documents' do
      expect(controller.url_for_document(multi_exhibit_document)).to eq '#'
    end
  end

  describe '#exhibit_tags_facet_query_config' do
    subject(:config) { controller.exhibit_tags_facet_query_config }

    before do
      create(:exhibit, slug: 'a', published: true, tag_list: %w(foo bar))
      create(:exhibit, slug: 'b', published: true, tag_list: ['bar'])
      create(:exhibit, slug: 'c', published: true, tag_list: %w(bar baz))
      create(:exhibit, slug: 'private', published: false, tag_list: %w(foo private))
    end

    it 'does nothing for unpublished exhibits' do
      expect(config.keys).not_to include 'private'
      expect(config['foo'][:fq]).not_to include 'private'
    end

    it 'constructs facet queries for each tag' do
      expect(config.keys).to match_array %w(foo bar baz)
      expect(config['foo'][:fq]).to eq "#{SolrDocument.exhibit_slug_field}:(a)"
      expect(config['bar'][:fq]).to eq "#{SolrDocument.exhibit_slug_field}:(a OR b OR c)"
      expect(config['baz'][:fq]).to eq "#{SolrDocument.exhibit_slug_field}:(c)"
    end
  end
end
