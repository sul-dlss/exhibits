# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Full text highlighting' do
  let(:exhibit) { create(:exhibit) }
  let(:dor_harvester) { DorHarvester.new(druid_list: druid, exhibit: exhibit) }
  let(:user) { create(:exhibit_admin, exhibit: exhibit) }

  before do
    allow(Spotlight::Engine.config).to receive(:filter_resources_by_exhibit).and_return(false)

    # Enable the full text field for display
    sign_in user
    visit spotlight.edit_exhibit_metadata_configuration_path(exhibit)
    page.find('#blacklight_configuration_index_fields_full_text_tesimv_list').click
    click_button 'Save changes'
    sign_out user
  end

  context 'when a document has a full text highlight hit' do
    it 'shows the full-text hightlight field and provides a toggle', js: true do
      visit spotlight.search_exhibit_catalog_path(exhibit, q: 'structure')

      expect(page).to have_css('dt', text: 'Sample matches in document text')

      expect(page).not_to have_css('dd p', text: 'about need for data structures capable of storing', visible: true)
      page.find('dt', text: 'Sample matches in document text').click
      expect(page).to have_css('dd p', text: 'about need for data structures capable of storing', visible: true)
    end
  end

  context 'when a document has non-english full text' do
    it 'stems Portuguese properly', js: true do
      visit spotlight.search_exhibit_catalog_path(exhibit, q: 'homens')

      expect(page).not_to have_css('dd p', text: 'em conta o homem normal suposto', visible: true)
      page.find('dt', text: 'Sample matches in document text').click
      expect(page).to have_css('dd p', text: 'em conta o homem normal suposto', visible: true)
    end
  end

  context 'when a document does not have a full text highlight hit' do
    it 'does not include full-text highlight', js: true do
      visit spotlight.search_exhibit_catalog_path(exhibit, q: 'Maps')

      expect(page).to have_css('.documents-list .document') # there are results

      expect(page).not_to have_css('dt', text: 'Sample matches in document text')
    end
  end
end
