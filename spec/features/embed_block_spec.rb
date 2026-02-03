# frozen_string_literal: true

require 'rails_helper'
# Gem::Specificationfind_by_name is not a rails dynamic finder
# require "#{Gem::Specification.find_by_name('blacklight-spotlight').gem_dir}/spec/support/features/test_features_helpers"

# just like #fill_in_typeahead_field, but wait for the
# form fields/thumbnail preview to show up on the page too
def fill_in_solr_document_block_typeahead_field(page, opts)
  expect(page).to have_selector('.st-blocks.st-ready')
  fill_in_typeahead_field(page, opts)
  expect(page).to have_css("input[value=\"#{opts[:with]}\"]", visible: false)
  expect(page).to have_css("li[data-resource-id=\"#{opts[:with]}\"] .img-thumbnail[src^=\"http\"]")
end

def fill_in_typeahead_field(page, opts = {})
  type = opts[:type] || 'default'

  # Role=combobox indicates that the auto-complete is initialized
  find("auto-complete [data-#{type}-typeahead][role='combobox']").fill_in(with: opts[:with])
  # Wait for the autocomplete to show both 'open' and 'aria-expanded="true"' or the results might be stale
  expect(page).to have_css("auto-complete[open] [data-#{type}-typeahead][role='combobox'][aria-expanded='true']")
  expect(page).to have_css("auto-complete[open] [role='option']", text: opts[:with])
  first('auto-complete[open] [role="option"]', text: opts[:with]).click
end

def add_widget(page, type)
  click_add_widget(page)

  # click the item + image widget
  expect(page).to have_css("button[data-type='#{type}']")
  find("button[data-type='#{type}']").click
end

def click_add_widget(page)
  if all('.st-block-replacer').blank?
    expect(page).to have_css('.st-block-addition')
    first('.st-block-addition').click
  end
  expect(page).to have_css('.st-block-replacer')
  first('.st-block-replacer').click
end

def save_page_changes(page)
  click_button('Save changes')
  # verify that the page was created.
  expect(page).to have_selector('.alert-info', text: 'was successfully updated')
  expect(page).to have_no_selector('.alert-danger')
end

def wait_for_sir_trevor(page)
  expect(page).to have_selector('.st-blocks.st-ready')
end

RSpec.feature 'Solr Documents Embed Block', :js do
  # include Spotlight::TestFeaturesHelpers

  let(:exhibit) { create(:exhibit) }
  let(:curator) { create(:exhibit_admin, exhibit: exhibit) }

  before do
    allow(Spotlight::Engine.config).to receive(:filter_resources_by_exhibit).and_return(false)
    sign_in curator

    stub_request(:get, 'http://purl.stanford.edu/embed.json')
      .with(query: hash_including({ 'url' => 'https://purl.stanford.edu/zy575vf8599', 'maxheight' => '600' }))
      .to_return(status: 200, body: File.read(File.join(FIXTURES_PATH, 'purl_embed/600/zy575vf8599.json')))

    stub_request(:get, 'http://purl.stanford.edu/embed.json')
      .with(query: hash_including({ 'url' => 'https://purl.stanford.edu/zy575vf8599', 'maxheight' => '300' }))
      .to_return(status: 200, body: File.read(File.join(FIXTURES_PATH, 'purl_embed/300/zy575vf8599.json')))

    visit spotlight.edit_exhibit_home_page_path(exhibit)

    wait_for_sir_trevor(page)
    add_widget(page, 'solr_documents_embed')
  end

  describe 'block editing form' do
    it 'has a number field to input the hight (with a default placeholder)' do
      fill_in_solr_document_block_typeahead_field(page, with: 'zy575vf8599')

      expect(page).to have_css('label', text: 'Maximum height of viewer (in pixels)')
      number_input = page.find('input[type="number"][placeholder]')
      expect(number_input['placeholder']).to eq '600'
      expect(number_input.value).to eq ''

      save_page_changes(page)

      expect(page.find('.items-block iframe')['height']).to eq '600px'
    end

    it 'allows curators to set the maxheight paramter sent to the Embed' do
      fill_in_solr_document_block_typeahead_field(page, with: 'zy575vf8599')
      fill_in 'Maximum height of viewer (in pixels)', with: 300

      save_page_changes(page)
      expect(page.find('.items-block iframe')['height']).to eq '300px'
    end

    it 'allows curators to select the image area' do
      fill_in_solr_document_block_typeahead_field(page, with: 'zy575vf8599')

      expect(page).to have_css('.select-image-area')
    end
  end
end
