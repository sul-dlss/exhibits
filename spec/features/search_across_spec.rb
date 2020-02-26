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

  before do
    # "touch" published exhibits so they are created (and users aren't routed to a single exhibit)
    published_exhibit_without_document
    published_exhibit_with_document
  end

  context 'as an anonymous user' do
    it 'they can search across exhibits they have access to' do
      visit root_path
      within(first('.search-query-form')) do
        click_button 'Search'
      end

      expect(page).to have_css('#sortAndPerPage .page-entries', text: '1 item found')

      within '#facets .facet-limit.blacklight-spotlight_exhibit_slugs_ssim', visible: false do
        expect(page).to have_css('.facet-label', text: published_exhibit_with_document.title, visible: false)
        expect(page).not_to have_css('.facet-label', text: unpublished_exhibit_with_documents.title, visible: false)
      end
    end

    it 'has no item visibility facet' do
      visit root_path
      within(first('.search-query-form')) do
        click_button 'Search'
      end

      expect(page).not_to have_css('.card', text: 'Item Visibility')
    end
  end

  context 'as a user who is an admin' do
    before { sign_in exhibit_admin }

    it 'they can search across exhibits they have access to' do
      visit root_path
      within(first('.search-query-form')) do
        click_button 'Search'
      end

      expect(page).to have_css('#sortAndPerPage .page-entries', text: /1 - 10 of \d{2,} items/)

      within '#facets .facet-limit.blacklight-spotlight_exhibit_slugs_ssim', visible: false do
        expect(page).to have_css('.facet-label', text: unpublished_exhibit_with_documents.title, visible: false)
      end
    end

    it 'has an item visibility facet' do
      visit root_path
      within(first('.search-query-form')) do
        click_button 'Search'
      end

      click_button 'Item Visibility'
      click_link 'Private'

      expect(page).to have_content 'Kaart van Zuid-Afrika'
    end
  end
end
