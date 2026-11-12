# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Table of contents display', :js do
  let(:exhibit) { create(:exhibit, slug: 'default-exhibit') }
  let(:druid) { 'ab123toc4567' }
  # Modeled on a Parker manuscript (hq758xw3987), whose contents are a single "--"-separated value
  let(:document) do
    {
      id: druid,
      'exhibit_default-exhibit_public_bsi': true,
      'spotlight_exhibit_slug_default-exhibit_bsi': true,
      spotlight_exhibit_slugs_ssim: ['default-exhibit'],
      title_display: 'Sermones quadragesimales',
      format_main_ssim: ['Manuscript'],
      toc_search: ['Sermones quadragesimales -- Homiliae quatuor super Missus est -- Two sermons']
    }
  end

  before do
    Blacklight.default_index.connection.add(document)
    Blacklight.default_index.connection.commit
  end

  after do
    Blacklight.default_index.connection.delete_by_id(druid)
    Blacklight.default_index.connection.commit
  end

  it 'toggles the contents and keeps the link label in sync' do
    visit spotlight.exhibit_solr_document_path(exhibit, druid)

    toggle = find('a.show-hide-toggle', text: 'Show')
    expect(page).to have_no_css('li', text: 'Homiliae quatuor super Missus est', visible: :visible)

    toggle.click
    expect(page).to have_css('li', text: 'Homiliae quatuor super Missus est', visible: :visible)
    expect(toggle).to have_text('Hide')
    expect(page).to have_css('.collapse.show') # wait for the transition to finish

    toggle.click
    expect(page).to have_no_css('li', text: 'Homiliae quatuor super Missus est', visible: :visible)
    expect(toggle).to have_text('Show')
  end
end
