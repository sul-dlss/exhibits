# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Blacklight heatmaps', js: true do
  let!(:exhibit) { create(:exhibit, slug: 'default-exhibit') }

  describe 'accessing from CatalogController context' do
    it 'renders the leaflet map with results' do
      visit spotlight.search_exhibit_catalog_path(exhibit, q: ' ', view: 'heatmaps', search_field: 'all_fields')
      expect(page).to have_css '.leaflet-map-pane'
      expect(page).to have_css 'svg g path'
      expect(page).to have_css '.page-links', text: '16 items found'
    end
  end

  describe 'accessing from BrowseController context' do
    let!(:search) { FactoryBot.create(:search, title: 'Some Saved Search', exhibit: exhibit, published: true) }

    it 'renders the leaflet map with results' do
      visit spotlight.exhibit_browse_path(exhibit, search, view: 'heatmaps')
      expect(page).to have_css '.leaflet-map-pane'
      expect(page).to have_css 'svg g path'
    end
  end
end
