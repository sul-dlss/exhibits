# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchAcrossController do
  let(:view_context) { controller.view_context }

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

  describe '#url_for_document' do
    let(:document) do
      SolrDocument.new(id: 1, "#{SolrDocument.exhibit_slug_field}": ['a'])
    end

    it 'suppresses links for documents' do
      expect(view_context.url_for_document(document)).to eq '#'
    end
  end

  describe '#link_to_document' do
    let(:document) do
      SolrDocument.new(id: 'SomeId1', "#{SolrDocument.exhibit_slug_field}": ['abc'])
    end

    it 'links to exhibit documents' do
      expect(view_context.link_to_document(document, nil)).to eq 'SomeId1'
    end
  end

  describe '#show_pagination?' do
    before do
      controller.params[:group] = true
    end

    it 'is suppressed for grouped responses' do
      expect(view_context.show_pagination?).to eq false
    end
  end

  describe '#document_index_path_templates' do
    before do
      controller.params[:group] = true
    end

    it 'injects custom exhibits document partials' do
      expect(view_context.document_index_path_templates).to eq ['exhibit_%<index_view_type>s']
    end
  end

  describe '#render_document_index' do
    before do
      controller.params[:group] = true
    end

    let(:response) do
      Blacklight::Solr::Response.new({
                                       facet_counts: {
                                         facet_fields: {
                                           "#{SolrDocument.exhibit_slug_field}": {
                                             a: 1,
                                             b: 3,
                                             c: 15
                                           }
                                         }
                                       }
                                     }, nil)
    end

    let!(:exhibits) do
      [
        create(:exhibit, slug: 'a'),
        create(:exhibit, slug: 'b'),
        create(:exhibit, slug: 'c')
      ]
    end

    it 'replaces solr results with exhibits from the database' do
      controller.instance_variable_set(:@response, response)
      allow(view_context).to receive(:render_document_index_with_view).and_return('rendered')
      rendered = view_context.render_document_index(response.documents)

      expect(rendered).to eq 'rendered'
      expect(view_context).to have_received(:render_document_index_with_view).with(:list, exhibits, {})
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

  describe '#exhibit_visibility_query_config' do
    subject(:config) { controller.exhibit_visibility_query_config }

    let(:exhibit) do
      create(:exhibit, slug: 'mine', published: true, tag_list: ['bar'])
    end
    let(:user) { create(:exhibit_admin, exhibit: exhibit) }

    before do
      sign_in user
      create(:exhibit, slug: 'other')
    end

    it 'constructs facet queries for each exhibit the user can curate' do
      expect(config.keys).to match_array %i(private)
      expect(config[:private][:fq]).to include 'exhibit_mine_public_bsi:false'
      expect(config[:private][:fq]).not_to include 'exhibit_other_public_bsi:false'
    end
  end
end
