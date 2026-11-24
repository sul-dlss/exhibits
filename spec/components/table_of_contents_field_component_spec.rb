# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TableOfContentsFieldComponent, type: :component do
  subject(:rendered) { render_inline(described_class.new(field:)) }

  let(:document) { SolrDocument.new(id: 'cf386wt1778', toc_search: value) }
  let(:field_config) { CatalogController.blacklight_config.index_fields['toc_search'] }
  let(:field) { Blacklight::FieldPresenter.new(vc_test_controller.view_context, document, field_config) }

  before do
    allow(field).to receive(:render_field?).and_return(true)
  end

  context 'with a single value' do
    let(:value) { ['Homiliae'] }

    it 'presents content inline' do
      expect(rendered.css('dd').text).to eq 'Homiliae'
      expect(rendered).to have_no_css '[data-bs-toggle="collapse"]'
    end
  end

  context 'with a multi-valued table of contents' do
    let(:value) { ['Homiliae -- euangelia'] }

    it 'separates MODS table of contents' do
      expect(rendered.css('dd ul').inner_html.strip).to eq '<li>Homiliae</li><li>euangelia</li>'
    end

    it 'collapses content' do
      expect(rendered).to have_css 'a.show-hide-toggle[data-bs-toggle="collapse"][href="#collapseToc-cf386wt1778"]'
      expect(rendered).to have_css 'div.collapse#collapseToc-cf386wt1778'
    end
  end

  context 'without a value' do
    let(:value) { [] }

    it 'renders nothing' do
      expect(rendered.to_html).to be_blank
    end
  end

  describe 'non-HTML rendering (e.g. the JSON API)' do
    let(:value) { ['Homiliae--euangelia'] }

    it 'renders the separated entries' do
      expect(field.render).to eq %w(Homiliae euangelia)
    end

    context 'with a single value' do
      let(:value) { ['Homiliae'] }

      it 'renders the value' do
        expect(field.render).to eq %w(Homiliae)
      end
    end
  end
end
