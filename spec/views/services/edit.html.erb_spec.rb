require 'rails_helper'

describe 'services/edit.html.erb', type: :view do
  let(:exhibit) { create(:exhibit) }
  let(:bibliography_service) { BibliographyService.create(exhibit_id: exhibit.id) }

  before do
    assign(:bibliography_service, bibliography_service)
    assign(:exhibit, exhibit)
    expect(view).to receive_messages(configuration_page_title: 'Service')
    stub_template 'spotlight/shared/_exhibit_sidebar.html.erb' => 'ignore'
    render
  end

  context 'an unsynchronized bibliography service' do
    it 'displays a note indidcating that status' do
      expect(rendered).to have_content 'Exhibit items have never been synchronized with a Zotero library'
    end

    it 'does not render a link to synchronize the service' do
      expect(rendered).not_to have_css('a', text: 'Synchronize with Zotero')
    end
  end

  context 'a synchronized bibliography service' do
    let(:bibliography_service) do
      BibliographyService.create(exhibit_id: exhibit.id, sync_completed_at: DateTime.current)
    end

    it 'displays a note indidcating that status' do
      expect(rendered).to have_content 'Exhibit items were last synced with your Zotero library on '
    end

    it 'renders a link to synchronize the service' do
      expect(rendered).to have_css('a', text: 'Synchronize with Zotero')
    end
  end
end
