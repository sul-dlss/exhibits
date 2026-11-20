# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CatalogHelper do
  describe '#exhibits_default_thumbnail' do
    before do
      expect(helper).to receive_messages(
        blacklight_config: CatalogController.blacklight_config,
        document_index_view_type: :list
      )
    end

    context 'for references' do
      let(:document) { SolrDocument.new(id: 'abc123', format_main_ssim: ['Reference']) }

      it 'renders a default thumbnail' do
        img = Capybara.string(helper.exhibits_default_thumbnail(document, {}))
        expect(img.find('img')['src']).to include 'default-square-thumbnail-book'
      end
    end

    context 'for canvases' do
      let(:document) { SolrDocument.new(id: 'abc123', format_main_ssim: ['Page details']) }

      it 'renders a default thumbnail' do
        img = Capybara.string(helper.exhibits_default_thumbnail(document, {}))
        expect(img.find('img')['src']).to include 'default-square-thumbnail-annotation'
      end
    end
  end
end
