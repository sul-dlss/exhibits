require 'rails_helper'

describe 'Viewers', type: :feature do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:user) { nil }

  before do
    sign_in user
  end

  context 'an authorized user' do
    let(:user) { create(:exhibit_admin, exhibit: exhibit) }

    it 'sees the default configuration' do
      visit spotlight.exhibit_dashboard_path(exhibit)

      within('#sidebar') do
        click_link 'Viewers'
      end

      expect(field_labeled('SUL-Embed')[:checked]).to eq 'checked'
    end

    it 'can edit the viewers configuration' do
      visit spotlight.exhibit_dashboard_path(exhibit)

      within('#sidebar') do
        click_link 'Viewers'
      end

      choose 'Mirador'

      click_button 'Save changes'

      expect(field_labeled('Mirador')[:checked]).to eq 'checked'
    end

    it 'includes breadcrumbs on the edit page' do
      visit edit_exhibit_viewers_path(exhibit)

      within('ul.breadcrumb') do
        expect(page).to have_link 'Home'
        expect(page).to have_link 'Configuration'
        expect(page).to have_css('li.active', text: 'Viewers')
      end
    end
  end
end
