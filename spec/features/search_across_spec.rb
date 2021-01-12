# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Searching Across Exhibits', type: :feature do
  let(:published_exhibit_without_document) do
    FactoryBot.create(:exhibit, published: true)
  end
  let(:published_exhibit_with_document) do
    FactoryBot.create(:exhibit, published: true, slug: 'test-exhibit')
  end
  let(:unpublished_exhibit_with_documents) do
    FactoryBot.create(:exhibit, published: false, slug: 'default-exhibit')
  end
  let(:exhibit_admin) { FactoryBot.create(:exhibit_admin, exhibit: unpublished_exhibit_with_documents) }
  let(:tag1) do
    FactoryBot.create(:tagging, tagger: published_exhibit_with_document, taggable: published_exhibit_with_document)
  end

  before do
    # "touch" fixtures that need to be created before a user visits the app
    published_exhibit_without_document
    published_exhibit_with_document
    tag1
  end

  context 'as an anonymous user' do
    it 'they can search across exhibits they have access to', js: true do
      visit root_path
      within(first('.search-query-form')) do
        click_button 'Search'
      end

      expect(page).to have_css('#sortAndPerPage .page-entries', text: '1 item found')

      within '#facets .facet-limit.blacklight-spotlight_exhibit_slugs_ssim', visible: false do
        expect(page).to have_css('.facet-label', text: published_exhibit_with_document.title, visible: :hidden)
        expect(page).not_to have_css('.facet-label', text: unpublished_exhibit_with_documents.title, visible: :hidden)
      end
    end

    it 'has no item visibility facet' do
      visit root_path
      within(first('.search-query-form')) do
        click_button 'Search'
      end

      expect(page).not_to have_css('.card', text: 'Item Visibility')
    end

    it 'renders the appropriate page title' do
      visit root_path
      within(first('.search-query-form')) do
        fill_in :q, with: 'map'
        click_button 'Search'
      end

      expect(page.title).to start_with('map')
    end

    it 'links the start over link to the home page' do
      visit root_path
      within(first('.search-query-form')) do
        fill_in :q, with: 'map'
        click_button 'Search'
      end
      expect(page).to have_link 'Start over', href: '/'
    end

    it 'renders the appropriate facets in correct order' do
      visit root_path
      within(first('.search-query-form')) do
        click_button 'Search'
      end

      within '#facets', visible: false do
        facet_labels = page.all('h3').map(&:text)
        expect(facet_labels.first).to eq 'Exhibit category'
        expect(facet_labels).to include('Exhibit category', 'Exhibit title')
      end
    end
  end

  context 'as a user who is an admin' do
    before { sign_in exhibit_admin }

    it 'they can search across exhibits they have access to', js: true do
      visit root_path
      within(first('.search-query-form')) do
        click_button 'Search'
      end

      expect(page).to have_css('#sortAndPerPage .page-entries', text: /1 - 12 of \d{2,} items/)

      within '#facets .facet-limit.blacklight-spotlight_exhibit_slugs_ssim', visible: false do
        expect(page).to have_css('.facet-label', text: unpublished_exhibit_with_documents.title, visible: :hidden)
      end
    end

    it 'has an item visibility facet' do
      visit root_path
      within(first('.search-query-form')) do
        click_button 'Search'
      end

      click_button 'Item visibility'
      click_link 'Private'

      expect(page).to have_content 'Kaart van Zuid-Afrika'
    end

    it 'only passes through relevant parameters information' do
      visit search_search_across_path(
        group: true, range: { pub_year_tisim: { begin: 1879, end: 1890 } },
        f: { spotlight_exhibit_slugs_ssim: ['default-exhibit'] }
      )

      expect(page).to have_link href: '/default-exhibit'
      expect(page).to have_content '13 results'

      click_link '13 results'
      expect(page).to have_content '1 - 12 of 13'
    end
  end
end
