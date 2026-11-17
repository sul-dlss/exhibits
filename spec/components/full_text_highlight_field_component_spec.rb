# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FullTextHighlightFieldComponent, type: :component do
  subject(:rendered) { render_inline(described_class.new(field:)) }

  let(:document) { SolrDocument.new(druid: 'abc123', full_text_tesimv: true) }
  let(:field_config) { CatalogController.blacklight_config.index_fields['full_text_tesimv'] }
  let(:field) { Blacklight::FieldPresenter.new(vc_test_controller.view_context, document, field_config) }
  let(:params) { {} }

  before do
    allow(document).to receive(:full_text_highlights).and_return(highlights)
    allow(field).to receive(:render_field?).and_return(true)
    allow(vc_test_controller).to receive_messages(
      current_exhibit: create(:exhibit, slug: 'exhibit-slug'),
      params: ActionController::Parameters.new(params)
    )
  end

  context 'when there is a matching highlight for the given document' do
    let(:highlights) { ['The first <em>Value1</em>', 'The <em>Value2</em> second'] }

    it 'wraps each highlight value in a paragraph tag' do
      expect(rendered.css('dd').inner_html).to eq '<div data-controller="full-text-collapse">' \
                                                  '<p>The first <em>Value1</em></p><p>The <em>Value2</em> second</p>' \
                                                  '</div>'
    end
  end

  context 'when there are more than the configured amount of highlight snippets returned' do
    let(:highlights) { %w(Value1 Value2 Value3 Value4 Value5 Value6 Value7 Value8) }

    it 'only renders the configured amount of snippets' do
      expect(rendered).to have_css('dd p', count: Settings.full_text_highlight.snippet_count)
    end
  end

  context 'when there is a q param' do
    let(:highlights) { %w(Value1 Value2) }
    let(:params) { { q: 'The search term' } }

    it 'offers a link to go the record view w/ a search initiated' do
      link = rendered.css('dd div[data-controller="full-text-collapse"] a.prepared-search-link').first
      expect(link.text).to eq('Search for "The search term" in document text')
      expect(link['href']).to eq('/exhibit-slug/catalog/abc123?search=The+search+term')
    end

    context 'when the response does not include highlighting for the given document' do
      let(:highlights) { [] }

      it 'renders only the link' do
        expect(rendered).to have_css('dd a.prepared-search-link')
        expect(rendered).to have_no_css('dd p')
      end
    end
  end

  context 'when the response does not include highlighting for the given document' do
    let(:highlights) { [] }

    it 'renders nothing' do
      expect(rendered.to_html).to be_blank
    end
  end
end
