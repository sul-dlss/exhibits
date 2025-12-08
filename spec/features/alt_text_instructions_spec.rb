# frozen_string_literal: true

require 'rails_helper'
require "#{Gem::Specification.find_by_name('blacklight-spotlight').gem_dir}/spec/support/features/test_features_helpers"

describe 'Alt text instructions', :js do
  include Spotlight::TestFeaturesHelpers

  let(:exhibit) { create(:exhibit) }
  let(:exhibit_curator) { create(:exhibit_curator, exhibit: exhibit) }

  before do
    login_as exhibit_curator
    visit spotlight.edit_exhibit_home_page_path(exhibit)
    add_widget 'uploaded_items'
  end

  it 'displays alternative text guidelines with the customized link' do
    expect(page).to have_content('For each item, please enter alternative text')
    expect(page).to have_link('Guidelines for writing alt text.', href: 'https://uit.stanford.edu/accessibility/concepts/images')
  end
end
