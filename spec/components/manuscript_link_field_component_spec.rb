# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ManuscriptLinkFieldComponent, type: :component do
  subject(:rendered) { render_inline(described_class.new(field:)) }

  let(:druid) { 'bg021sq9590' }
  let(:show_page) { "/test-flag-exhibit-slug/catalog/#{druid}" }
  let(:field_config) { CatalogController.blacklight_config.index_fields['related_document_id_ssim'] }
  let(:field) { Blacklight::FieldPresenter.new(vc_test_controller.view_context, document, field_config) }

  before do
    allow(vc_test_controller).to receive(:current_exhibit).and_return(create(:exhibit, slug: 'test-flag-exhibit-slug'))
    allow(field).to receive(:render_field?).and_return(true)
  end

  context 'with page details' do
    let(:title) { 'Baldwin of Ford OCist, De sacramento altaris' }
    let(:document) do
      SolrDocument.new(
        title_display: "p. 3:#{title}",
        related_document_id_ssim: [druid],
        format_main_ssim: ['Page details']
      )
    end

    it 'removes page prefix if present' do
      expect(rendered).to have_link(title, href: show_page)
    end
  end

  context 'with a bibliography resource' do
    let(:document) do
      SolrDocument.new(
        title_display: 'A Zotero reference',
        related_document_id_ssim: [druid],
        format_main_ssim: ['Bibliography']
      )
    end

    it 'displays druid for Bibliography resources' do
      expect(rendered).to have_link(druid, href: show_page)
    end
  end
end
