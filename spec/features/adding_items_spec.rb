# frozen_string_literal: true

require 'rails_helper'
require "#{Gem::Specification.find_by_name('blacklight-spotlight').gem_dir}/spec/support/features/test_features_helpers"

RSpec.feature 'Adding items to an exhibit' do
  include Spotlight::TestFeaturesHelpers

  let(:exhibit) { create(:exhibit) }
  let(:user) { create(:exhibit_admin, exhibit: exhibit) }
  let(:number_of_resources) { 5 }
  let(:resource) { DorHarvester.create(exhibit: exhibit) }

  before do
    sign_in user

    number_of_resources.times do |i|
      Spotlight::SolrDocumentSidecar.create(
        exhibit: exhibit,
        resource: resource,
        document: SolrDocument.new(id: "abc#{i}"),
        index_status: { ok: true }
      )
    end
  end

  context 'when the number of documents is below the threshold', js: true do
    it 'displays the item statuses as a table' do
      visit spotlight.new_exhibit_resource_path(exhibit)

      within '#sdr-item-status' do
        click_button 'Item status'
      end

      within '#status-accordion' do
        click_button 'Object druids'

        expect(page).to have_css('table th', text: 'Druid')
        expect(page).to have_css('table th', text: 'Status')
        expect(page).to have_css('table tbody tr', count: number_of_resources)
      end
    end
  end

  context 'when the number of documents is above the threshold', js: true do
    let(:number_of_resources) { 11 }

    it 'displays a form input that allows users to search for a druid' do
      visit spotlight.new_exhibit_resource_path(exhibit)

      within('#sdr-item-status') { click_button 'Item status' }

      within '#status-accordion' do
        click_button 'Object druids'

        expect(page).to have_content("There are #{number_of_resources} object druids indexed in this exhibit")

        fill_in_typeahead_field type: 'index-status', with: 'abc1'

        expect(page).to have_css('tr[data-index-status-id="abc1"] td', text: 'abc1', visible: :visible)
        expect(page).to have_css('td[data-behavior="index-item-status"]', text: 'Published')
      end
    end

    context 'when an indexing error occurs' do
      before do
        Spotlight::SolrDocumentSidecar.create(
          exhibit: exhibit,
          resource: resource,
          document: SolrDocument.new(id: 'xyz'),
          index_status: { ok: false, message: 'There was a problem indexing' }
        )
      end

      it 'renders the message as a status' do
        visit spotlight.new_exhibit_resource_path(exhibit)

        within('#sdr-item-status') { click_button 'Item status' }

        within '#status-accordion' do
          click_button 'Object druids'

          fill_in_typeahead_field type: 'index-status', with: 'xyz'

          expect(page).to have_css('tr.danger[data-index-status-id="xyz"] td', text: 'xyz', visible: :visible)
          expect(page).to have_css('td[data-behavior="index-item-status"]', text: 'There was a problem indexing')
        end
      end
    end
  end
end
