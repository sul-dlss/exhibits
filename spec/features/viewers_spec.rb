# frozen_string_literal: true

require 'rails_helper'

describe 'Viewers', type: :feature do
  let(:exhibit) { create(:exhibit, slug: 'default-exhibit') }
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
  describe 'rendered viewer' do
    let(:feature_page) { FactoryBot.create(:feature_page, title: 'Parent Page', exhibit: exhibit) }
    # FIXME: Not really sure here how to setup a embedded solr document here. This is an attempt but still pending
    let(:content) do
      SirTrevorRails::Blocks::SolrDocumentsEmbedBlock.from_hash(
        {
          type: 'block',
          title: 'stuff',
          'text-align' => 'left',
          text: '<p>more text</p>',
          item: {
            item_0: {
              id: 'hj066rn6500',
              title: 'Basic',
              thumbnail_image_url: '',
              full_image_url: '',
              iiif_tilesource: 'https://stacks.stanford.edu/image/iiif/hj066rn6500%2Fhj066rn6500_00_0001/info.json',
              iiif_manifest_url: 'https://purl.stanford.edu/hj066rn6500/iiif/manifest',
              iiif_canvas_id: 'https://purl.stanford.edu/hj066rn6500/iiif/canvas/hj066rn6500_1',
              iiif_image_id: 'https://purl.stanford.edu/hj066rn6500/iiif/annotation/hj066rn6500_1',
              weight: '0',
              display: 'true'
            }
          }
        },
        nil
      )
    end

    before do
      exhibit.required_viewer.viewer_type = 'mirador'
      exhibit.required_viewer.save
      feature_page.content = content
      content.save
    end
    it 'renders configured viewer on show page' do
      visit spotlight.exhibit_solr_document_path(exhibit, 'hj066rn6500')
      expect(page).to have_css 'iframe[src*=mirador]'
      expect(page).not_to have_css '.oembed-widget'
    end
    pending 'renders default viewer on configured widget feature page' do
      visit spotlight.exhibit_feature_page_path(exhibit, feature_page)
      expect(page).not_to have_css 'iframe[src*=mirador]'
      expect(page).to have_css '.oembed-widget'
    end
  end
end
