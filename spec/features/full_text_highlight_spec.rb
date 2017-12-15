# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Full text highlighting' do
  let(:exhibit) { create(:exhibit) }
  let(:dor_harvester) { DorHarvester.new(druid_list: druid, exhibit: exhibit) }

  before do
    allow(Spotlight::Engine.config).to receive(:filter_resources_by_exhibit).and_return(false)
  end

  context 'when a document has a full text highlight hit' do
    it 'shows the full-text hightlight field and provides a toggle', js: true do
      visit spotlight.search_exhibit_catalog_path(exhibit, q: 'structure')

      expect(page).to have_css('dt', text: 'Preview matches in document text')

      expect(page).not_to have_css('dd p', text: 'about need for data structures capable of storing', visible: true)
      page.find('dt', text: 'Preview matches in document text').click
      expect(page).to have_css('dd p', text: 'about need for data structures capable of storing', visible: true)
    end
  end

  context 'when a document does not have a full text highlight hit' do
    it 'does not include full-text highlight', js: true do
      visit spotlight.search_exhibit_catalog_path(exhibit, q: 'Maps')

      expect(page).to have_css('.documents-list .document') # there are results

      expect(page).not_to have_css('dt', text: 'Preview matches in document text')
    end
  end
end
