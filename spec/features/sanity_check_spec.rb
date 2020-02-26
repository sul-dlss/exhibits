# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sanity checking upstream dependencies', type: :feature do
  let(:exhibit) { create(:exhibit, slug: 'default-exhibit') }

  describe 'the catalog record page' do
    it 'shows the fields we expect to see' do
      visit spotlight.exhibit_solr_document_path(exhibit, 'wk210cf6868')

      [
        'Title', 'Topic', 'Language', 'Physical Description',
        'Publication Info', 'Imprint', 'Notes', 'Collection', 'Inline Map'
      ].each do |expected_field|
        expect(page).to have_selector 'dt', text: expected_field
      end
    end
  end
end
