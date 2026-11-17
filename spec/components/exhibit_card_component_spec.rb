# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExhibitCardComponent, type: :component do
  subject(:rendered) do
    render_inline(described_class.new(exhibit:, response:, search_state:, view_type:))
  end

  let(:exhibit) do
    create(:exhibit, slug: 'abc', title: 'Alphabet', subtitle: 'Letters', description: 'All about letters')
  end
  let(:view_type) { :list }
  let(:blacklight_config) { SearchAcrossController.blacklight_config }
  let(:response) do
    Blacklight::Solr::Response.new(
      { facet_counts: { facet_fields: { SolrDocument.exhibit_slug_field => { 'abc' => 13, 'xyz' => 2 } } } },
      nil,
      blacklight_config: blacklight_config
    )
  end
  let(:search_params) do
    ActionController::Parameters.new(
      q: 'some search', group: true, page: 15,
      f: { format_main_ssim: ['Book'], SolrDocument.exhibit_slug_field => ['abc'] }
    ).permit!
  end
  let(:search_state) { Blacklight::SearchState.new(search_params, blacklight_config, nil) }

  it 'renders the exhibit title, subtitle, and description' do
    expect(rendered).to have_css('h2.card-title.mb-0 a[href="/abc"]', text: 'Alphabet')
    expect(rendered).to have_css('.subtitle', text: 'Letters')
    expect(rendered).to have_css('.description', text: 'All about letters')
    expect(rendered).to have_css('img.default-thumbnail')
  end

  it 'links to the exhibit search with only the parameters that make sense within an exhibit' do
    link = rendered.css('a').find { |a| a.text == '13 results' }
    query = Rack::Utils.parse_nested_query(URI.parse(link['href']).query)

    expect(URI.parse(link['href']).path).to eq Spotlight::Engine.routes.url_helpers.search_exhibit_catalog_path(exhibit)
    expect(query).to eq('q' => 'some search', 'f' => { 'format_main_ssim' => ['Book'] })
  end

  it 'does not render an unpublished badge for a published exhibit' do
    expect(rendered).to have_no_css('.badge')
  end

  context 'with an unpublished exhibit in the list view' do
    let(:exhibit) { create(:exhibit, slug: 'abc', published: false) }

    it 'renders the badge next to the title' do
      expect(rendered).to have_css('h2.card-title span.badge.ms-1', text: 'Unpublished')
      expect(rendered).to have_no_css('.badge.unpublished')
    end
  end

  context 'with an unpublished exhibit in the gallery view' do
    let(:exhibit) { create(:exhibit, slug: 'abc', published: false) }
    let(:view_type) { :gallery }

    it 'renders the badge above the title' do
      expect(rendered).to have_css('.card-body > span.badge.unpublished', text: 'Unpublished')
      expect(rendered).to have_no_css('h2.card-title .badge')
    end
  end
end
