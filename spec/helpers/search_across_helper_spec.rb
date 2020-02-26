# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchAcrossHelper, type: :helper do
  describe '#search_without_group' do
    let(:search_state) do
      instance_double(
        'Blacklight::SearchState',
        params_for_search: { group: true }
      )
    end

    it 'removes the group key/value' do
      expect(helper).to receive_messages(
        search_state: search_state
      )
      expect(helper.search_without_group).to eq({})
    end
  end

  describe '#search_with_group' do
    let(:search_state) do
      instance_double(
        'Blacklight::SearchState',
        params_for_search: {}
      )
    end

    it 'removes the group key/value' do
      expect(helper).to receive_messages(
        search_state: search_state
      )
      expect(helper.search_with_group).to eq group: true
    end
  end

  describe '#render_exhibit_title' do
    let(:blacklight_config) { SearchAcrossController.blacklight_config }
    let(:response) do
      {
        response: {
          docs: [
            { "#{SolrDocument.exhibit_slug_field}": ['abc'] },
            { "#{SolrDocument.exhibit_slug_field}": %w(abc 123 private) },
            { "#{SolrDocument.exhibit_slug_field}": ['private'] }
          ]
        }
      }
    end

    let(:doc) do
      SolrDocument.new(
        id: 1,
        SolrDocument.exhibit_slug_field => %w(abc 123 private)
      )
    end
    let(:current_ability) { Ability.new(User.new) }

    before do
      assign(:response, Blacklight::Solr::Response.new(response, nil, blacklight_config: blacklight_config))
      allow(helper).to receive(:current_ability).and_return(current_ability)

      create(:exhibit, slug: 'abc', title: 'Alphabet')
      create(:exhibit, slug: '123', title: 'Numbers')
      create(:exhibit, slug: 'private', published: false, title: 'Secret')
    end

    it 'links to published exhibits by title' do
      actual = Capybara.string(helper.render_exhibit_title(document: doc, value: %w(abc 123 private)))
      expect(actual).to have_link text: 'Alphabet', href: spotlight.exhibit_solr_document_path(exhibit_id: 'abc', id: 1)
      expect(actual).to have_link text: 'Numbers', href: spotlight.exhibit_solr_document_path(exhibit_id: '123', id: 1)
      expect(actual).to have_css 'br'
      expect(actual).not_to have_link text: 'Secret'
    end
  end

  describe '#render_exhibit_title_facet' do
    let(:blacklight_config) { SearchAcrossController.blacklight_config }
    let(:response) do
      {
        facet_counts: {
          facet_fields: {
            "#{SolrDocument.exhibit_slug_field}": {
              a: 1,
              b: 3,
              c: 15
            }
          }
        }
      }
    end

    let(:current_ability) { Ability.new(User.new) }

    before do
      assign(:response, Blacklight::Solr::Response.new(response, nil, blacklight_config: blacklight_config))
      allow(helper).to receive(:current_ability).and_return(current_ability)

      create(:exhibit, slug: 'a', title: 'Alphabet')
      create(:exhibit, slug: 'b', published: false, title: 'Secret')
    end

    it 'translates exhibit slugs in the facets to titles' do
      expect(helper.render_exhibit_title_facet('a')).to eq 'Alphabet'
    end

    it 'hides private exhibits' do
      expect(helper.render_exhibit_title_facet('b')).to be_blank
    end
  end

  describe '#exhibit_metadata' do
    let(:response) do
      {
        response: {
          docs: [
            { "#{SolrDocument.exhibit_slug_field}": ['abc'] },
            { "#{SolrDocument.exhibit_slug_field}": %w(abc xyz) },
            { "#{SolrDocument.exhibit_slug_field}": ['private'] }
          ]
        }
      }
    end
    let(:blacklight_config) { SearchAcrossController.new.blacklight_config }
    let(:current_ability) { Ability.new(User.new) }

    before do
      assign(:response, Blacklight::Solr::Response.new(response, nil, blacklight_config: blacklight_config))
      create(:exhibit, slug: 'abc')
      create(:exhibit, slug: 'xyz')
      create(:exhibit, slug: 'private', published: false)
      allow(helper).to receive(:current_ability).and_return(current_ability)
    end

    it 'retrieves exhibit data from the database' do
      expect(helper.exhibit_metadata.keys).to match_array(%w(abc xyz))
    end
  end

  describe 'Blacklight overrides' do
    describe '#show_pagination?' do
      it 'is suppressed for grouped responses' do
        allow(helper).to receive(:render_grouped_response?).and_return(true)
        expect(helper.show_pagination?).to eq false
      end
    end

    describe '#document_index_path_templates' do
      it 'injects custom exhibits document partials' do
        allow(helper).to receive(:render_grouped_response?).and_return(true)
        expect(helper.document_index_path_templates).to eq ['exhibit_%<index_view_type>s']
      end
    end

    describe '#render_grouped_document_index' do
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

      let(:exhibits) do
        [
          create(:exhibit, slug: 'a'),
          create(:exhibit, slug: 'b'),
          create(:exhibit, slug: 'c')
        ]
      end

      it 'replaces solr results with exhibits from the database' do
        allow(helper).to receive(:render_document_index).with(exhibits).and_return('x')
        helper.render_grouped_document_index(response)
        expect(helper).to have_received(:render_document_index).with(exhibits)
      end
    end

    describe '#link_to_document' do
      let(:exhibit_document) do
        SolrDocument.new(id: 'Some title', "#{SolrDocument.exhibit_slug_field}": ['abc'])
      end
      let(:multi_exhibit_document) do
        SolrDocument.new(id: 'Some title', "#{SolrDocument.exhibit_slug_field}": %w(abc xyz))
      end
      let(:blacklight_config) { SearchAcrossController.new.blacklight_config }

      it 'links to exhibit documents' do
        expect(helper).to receive_messages(
          blacklight_config: blacklight_config,
          blacklight_configuration_context: Blacklight::Configuration::Context.new(SearchAcrossController.new),
          search_state: Blacklight::SearchState.new({}, blacklight_config),
          search_session: {},
          current_search_session: {}
        )
        expect(helper.link_to_document(exhibit_document, nil)).to eq '<a href="/catalog/Some%20title">Some title</a>'
      end

      it 'suppresses links for multi-exhibit documents' do
        expect(helper).to receive_messages(
          blacklight_config: blacklight_config,
          blacklight_configuration_context: Blacklight::Configuration::Context.new(SearchAcrossController.new)
        )
        expect(helper.link_to_document(multi_exhibit_document, nil)).to eq 'Some title'
      end
    end
  end
end
