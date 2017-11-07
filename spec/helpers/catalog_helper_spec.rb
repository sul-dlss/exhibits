# frozen_string_literal: true

require 'rails_helper'

describe CatalogHelper, type: :helper do
  describe '#has_thumbnail?' do
    context 'for references' do
      let(:document) { SolrDocument.new(format_main_ssim: ['Reference']) }

      it 'is true' do
        expect(has_thumbnail?(document)).to be true
      end
    end

    context 'for canvases' do
      let(:document) { SolrDocument.new(format_main_ssim: ['Page details']) }

      it { expect(has_thumbnail?(document)).to be true }
    end
  end

  describe '#render_thumbnail_tag' do
    before do
      expect(helper).to receive_messages(
        blacklight_config: CatalogController.blacklight_config,
        current_search_session: {},
        document_index_view_type: :list,
        search_state: instance_double('SearchState', url_for_document: '/'),
        search_session: {}
      )
    end
    context 'for references' do
      let(:document) { SolrDocument.new(id: 'abc123', format_main_ssim: ['Reference']) }

      it 'renders a default thumbnail' do
        link = Capybara.string(helper.render_thumbnail_tag(document))
        expect(link).to have_css('a[data-context-href]')
        expect(link.find('img')['src']).to include 'default-square-thumbnail-book'
      end
    end

    context 'for canveses' do
      let(:document) { SolrDocument.new(id: 'abc123', format_main_ssim: ['Page details']) }

      it 'renders a default thumbnail' do
        link = Capybara.string(helper.render_thumbnail_tag(document))
        expect(link).to have_css('a[data-context-href]')
        expect(link.find('img')['src']).to include 'default-square-thumbnail-annotation'
      end
    end
  end
end
