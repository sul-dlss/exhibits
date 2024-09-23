# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Hierarchy widget', :js do
  let(:exhibit) do
    create(:exhibit, published: true, slug: 'test-exhibit')
  end
  let(:admin) { create(:exhibit_admin, exhibit: exhibit) }

  before do
    login_as admin
    visit spotlight.search_exhibit_catalog_path(exhibit)
    page.driver.browser.manage.window.resize_to(1000, 400)
  end

  it 'has the Role facet' do
    expect(page).to have_button('Role')

    click_button 'Role'

    within '.blacklight-name_roles_ssim' do
      expect(page).to have_content('Artist')

      find('li', text: 'Artist').find('button').click

      expect(page).to have_content('Pellegrini, Domenico, 1759-1840')

      click_link 'Pellegrini'
    end

    expect(page).to have_css('.filter-value', text: 'Artist: Pellegrini, Domenico, 1759-1840')
  end

  it 'excludes empty roles from the Role facet' do
    expect(page).to have_button('Role')

    click_button 'Role'

    within '.blacklight-name_roles_ssim' do
      roles = find_all('li').map(&:text)

      expect(roles).not_to include ''
    end
  end
end
