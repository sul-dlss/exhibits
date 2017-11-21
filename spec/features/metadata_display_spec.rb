# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Metadata display' do
  let(:exhibit) { create(:exhibit, slug: 'default-exhibit') }

  describe 'page behavior' do
    before do
      visit spotlight.exhibit_solr_document_path(exhibit_id: exhibit.slug, id: 'gk885tn1705')
    end

    it 'view metadata link links through to page' do
      click_link 'View all metadata »'
      expect(page).to have_css 'h3', text: 'Metadata: Afrique Physique.'
      expect(page).to have_css 'dt', text: /Title/i
      expect(page).to have_css 'dd', text: 'Afrique Physique.'
      expect(page).to have_css 'a[download="gk885tn1705.mods.xml"]', text: 'Download'
    end
    it 'opens view metadata in modal', js: true do
      click_link 'View all metadata »'
      within '#ajax-modal' do
        expect(page).to have_css 'h3', text: 'Metadata: Afrique Physique.'
        expect(page).to have_css 'dt', text: /Title/i
        expect(page).to have_css 'dd', text: 'Afrique Physique.'
        expect(page).to have_css 'a[download="gk885tn1705.mods.xml"]', text: 'Download'
      end
    end
  end
  describe 'specific fields' do
    before do
      visit metadata_exhibit_solr_document_path(exhibit_id: exhibit.slug, id: 'gk885tn1705')
    end

    it 'has separate access conditions section' do
      expect(page).to have_css 'h4', text: 'Access conditions'
      expect(page).to have_css 'dt', text: 'Use and reproduction:'
      expect(page).to have_css 'dd', text: /To obtain permission/
      expect(page).to have_css 'dt', text: 'Copyright:'
      expect(page).to have_css 'dd', text: /Property rights reside with/
    end
  end
end
