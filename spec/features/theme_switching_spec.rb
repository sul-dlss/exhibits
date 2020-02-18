# frozen_string_literal: true

require 'rails_helper'

describe 'Theme switching', type: :feature do
  let(:exhibit) { create(:exhibit) }
  let(:user) { create(:exhibit_admin, exhibit: exhibit) }

  before { sign_in user }

  context 'Parker' do
    it 'allows the Parker theme to be selected' do
      allow(Settings).to receive(:exhibit_themes).and_return(exhibit.slug => %w(parker default))
      visit spotlight.exhibit_dashboard_path(exhibit)

      expect(page).to have_css('#global-footer', visible: true)
      expect(page).to have_css('#sul-footer', visible: true)

      within('#sidebar') { click_link 'Appearance' }

      choose 'Parker'

      click_button 'Save changes'

      expect(page).to have_css('#global-footer', visible: false)
      expect(page).to have_css('#sul-footer', visible: false)
    end
  end
end
