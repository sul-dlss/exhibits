require 'rails_helper'

describe 'boolean search queries', type: :feature do
  let(:exhibit) { FactoryGirl.create(:exhibit, slug: 'default-exhibit') }

  describe 'search results' do
    before do
      visit spotlight.url_for(exhibit)
      fill_in 'q', with: query
      click_button 'search'
    end

    context 'for a query with an uppercase OR' do
      let(:query) { 'Industries OR termthatdoesntexist' }
      it 'matches the single document about industries' do
        expect(page).to have_content '1 entry found'
      end
    end

    context 'for a query with a lowercase or' do
      let(:query) { 'Industries or termthatdoesntexist' }
      it 'matches no documents' do
        expect(page).to have_content 'No results found'
      end
    end
  end
end
