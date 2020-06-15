# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Searching Exhibits By Title', type: :feature, js: true do
  let(:exhibit1) do
    FactoryBot.create(:exhibit, published: true, slug: 'test-exhibit')
  end
  let(:exhibit2) do
    FactoryBot.create(:exhibit, published: true, slug: 'default-exhibit')
  end

  before do
    # "touch" fixtures that need to be created before a user visits the app
    exhibit1
    exhibit2
    allow(Settings.feature_flags).to receive(:exhibits_index).and_return(true)
    visit root_path
  end

  it 'provides a dropdown to choose search types' do
    within '#site-navbar .site-search-nav' do
      expect(page).to have_css('.dropdown-menu', visible: :hidden)
      click_button 'Find exhibits by title'
      expect(page).to have_css('.dropdown-menu', visible: :visible)

      within '.dropdown-menu' do
        expect(page).to have_link 'exhibits by title'
        expect(page).to have_link 'items in all exhibits'
      end
    end
  end

  describe 'the dropdown' do
    it 'provides a default option to autocomplete by exhibit title' do
      within '#site-navbar .site-search-nav' do
        expect(page).to have_css('button', text: 'Find exhibits by title')
        expect(page).to have_css('[data-behavior="exhibit-search-typeahead"]', visible: :visible)
      end
    end

    it 'provides an option to search items in exhibits' do
      expect(page).not_to have_css('form input#q', visible: :visible)

      within '#site-navbar .site-search-nav' do
        click_button 'Find exhibits by title'
        click_link 'items in all exhibits'

        expect(page).not_to have_css('button', text: 'Find exhibits by title')
        expect(page).to have_css('button', text: 'Find items in all exhibits')
      end

      fill_in 'q', with: 'Map'
      click_button 'Search'

      expect(page).to have_css('.sort-pagination .page-links .page-entries', text: /1 - 10 of \d+/)
    end
  end
end
