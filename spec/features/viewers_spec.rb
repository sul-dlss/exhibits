require 'rails_helper'

describe 'Viewers', type: :feature do
  let(:exhibit) { create(:exhibit) }
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

      within '#item-detail-page' do
        choose 'Mirador'
        click_button 'Save changes'
      end

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

    it 'allows updating a custom manifest URL pattern' do
      visit edit_exhibit_viewers_path(exhibit)

      within '#iiif-manifest' do
        fill_in 'viewer_custom_manifest_pattern', with: 'https://example.com/manifest/{id}'
        click_button 'Save changes'
      end

      expect(field_labeled('IIIF manifest URL pattern').value).to eq 'https://example.com/manifest/{id}'
    end

    it 'is invalid without {id}' do
      visit edit_exhibit_viewers_path(exhibit)

      within '#iiif-manifest' do
        fill_in 'viewer_custom_manifest_pattern', with: 'https://poorlyformed.com/manifest'
        click_button 'Save changes'
      end

      expect(page).to have_css '.alert.alert-warning', text: 'There was a problem updating the viewer settings'
      expect(field_labeled('IIIF manifest URL pattern').value).to be_nil
    end
  end
end
