# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Metadata display' do
  let(:exhibit) { create(:exhibit, slug: 'default-exhibit') }

  before do
    visit spotlight.exhibit_solr_document_path(exhibit_id: exhibit.slug, id: 'gk885tn1705')
  end

  it 'view metadata link links through to page' do
    click_link 'View all metadata »'
    expect(page).to have_css 'h3', text: 'Metadata: Afrique Physique.'
  end
  it 'opens view metadata in modal', js: true do
    click_link 'View all metadata »'
    within '#ajax-modal' do
      expect(page).to have_css 'h3', text: 'Metadata: Afrique Physique.'
    end
  end
end
