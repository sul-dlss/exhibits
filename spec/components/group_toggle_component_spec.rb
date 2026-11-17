# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupToggleComponent, type: :component do
  subject(:rendered) do
    with_controller_class(SearchAcrossController) do
      with_request_url('/search') { render_inline(described_class.new(response:, search_state:)) }
    end
  end

  let(:response) { instance_double(Blacklight::Solr::Response, documents:) }
  let(:documents) { [SolrDocument.new(id: 'abc')] }
  let(:search_state) do
    Blacklight::SearchState.new(params.merge(controller: 'search_across', action: 'index'),
                                SearchAcrossController.blacklight_config)
  end
  let(:params) { { q: 'cats' } }

  it 'labels the button group' do
    expect(rendered).to have_css('div.btn-group.search-group[role="group"][aria-label="Group results"]')
  end

  context 'when results are not grouped' do
    it 'links to both views and marks "All results" active' do
      expect(rendered).to have_link 'All results', href: '/search?q=cats', class: 'active'
      expect(rendered).to have_link 'Grouped by exhibit', href: '/search?group=true&q=cats'
      expect(rendered).to have_no_link 'Grouped by exhibit', class: 'active'
    end
  end

  context 'when results are grouped' do
    let(:params) { { q: 'cats', group: 'true' } }

    it 'removes the group param from "All results" and marks "Grouped by exhibit" active' do
      expect(rendered).to have_link 'All results', href: '/search?q=cats'
      expect(rendered).to have_no_link 'All results', class: 'active'
      expect(rendered).to have_link 'Grouped by exhibit', href: '/search?group=true&q=cats', class: 'active'
    end
  end

  context 'when there are no documents' do
    let(:documents) { [] }

    it 'renders nothing' do
      expect(rendered.to_html).to be_empty
    end
  end
end
