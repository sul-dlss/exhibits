# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Heatmaps view', :js do
  let(:exhibit) { create(:exhibit, published: true, slug: 'test-exhibit') }

  context 'when no results have geographic data' do
    it 'renders the map and an empty result count without erroring' do
      visit spotlight.search_exhibit_catalog_path(exhibit, view: 'heatmaps')

      expect(page).to have_css '.blacklight-heatmaps-index-map-container'
      expect(page).to have_css '#sortAndPerPage .page-links', text: /items? found/
    end
  end
end
