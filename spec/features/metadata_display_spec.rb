# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Metadata display' do
  let(:exhibit) { create(:exhibit, slug: 'default-exhibit') }
  let(:document_url) do
    spotlight.exhibit_solr_document_path(exhibit_id: exhibit.slug, id: 'gk885tn1705')
  end

  describe 'page behavior' do
    before do
      visit document_url
    end

    it 'view metadata link links through to page', js: false do
      click_link 'More details »'
      expect(page).to have_link 'Afrique Physique', href: document_url
      expect(page).to have_css 'h3', text: 'Afrique Physique'
      expect(page).not_to have_css 'dt', text: 'Title:'
      expect(page).to have_css 'a[download="gk885tn1705.mods.xml"]', text: 'Download'
    end

    it 'opens view metadata in modal', js: true do
      click_link 'More details »'
      within '#blacklight-modal' do
        expect(page).to have_css 'h3', text: 'Afrique Physique'
        expect(page).not_to have_css 'dt', text: 'Title:'
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

  describe 'nested related items', js: true do
    context 'in modal' do
      it 'are togglable' do
        visit spotlight.exhibit_solr_document_path(exhibit_id: exhibit.slug, id: 'gk885tn1705')
        click_link 'More details »'
        within '#blacklight-modal' do
          within '.mods_display_nested_related_items' do
            expect(page).to have_css('dl', visible: :hidden)
            click_link 'Constituent Title'
            expect(page).to have_css('dl', visible: :visible)
          end
        end
      end
    end

    context 'metadata page' do
      before do
        visit metadata_exhibit_solr_document_path(exhibit_id: exhibit.slug, id: 'gk885tn1705')
      end

      it 'are togglable' do
        within '.mods_display_nested_related_items' do
          expect(page).to have_css('dl', visible: :hidden)
          expect(page).to have_css('li a', text: 'Constituent Title')
          click_link 'Constituent Title'
          expect(page).to have_css('dl', visible: :visible)
          expect(page).to have_css('dt', text: /Note:/i)
          expect(page).to have_css('dd', text: 'Constituent note')
        end
      end

      it 'can toggle all' do
        click_link 'Expand all'
        within '.mods_display_nested_related_items' do
          expect(page).to have_css('dl', visible: :visible)
          expect(page).to have_css('dt', text: /Note:/i)
        end
        click_link 'Collapse all'
        within '.mods_display_nested_related_items' do
          expect(page).to have_css('dl', visible: :hidden)
          expect(page).to have_css('li a', text: 'Constituent Title')
        end
      end
    end
  end
end
