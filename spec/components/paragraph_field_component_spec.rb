# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ParagraphFieldComponent, type: :component do
  subject(:rendered) { render_inline(described_class.new(field:)) }

  let(:document) { SolrDocument.new(id: 'abc123', summary_display: value) }
  let(:field_config) { CatalogController.blacklight_config.index_fields['summary_display'] }
  let(:field) { Blacklight::FieldPresenter.new(vc_test_controller.view_context, document, field_config) }

  before do
    allow(field).to receive(:render_field?).and_return(true)
  end

  context 'with a single description' do
    let(:value) { %w(<p>stuff</p>) }

    it 'renders the description' do
      expect(rendered.css('dd').inner_html).to eq '<p>stuff</p>'
    end
  end

  context 'with multiple descriptions' do
    let(:value) { %W[<p>stuff</p> hello\nworld] }

    it 'renders the descriptions joined by paragraphs' do
      render_inline(described_class.new(field:))
      expect(rendered_content).to include '<p><p>stuff</p></p><p>hello</p><p>world</p>'
    end
  end

  context 'with tags that are not permitted' do
    let(:value) { ['<script>alert(1)</script><em>ok</em>'] }

    it 'sanitizes the content' do
      expect(rendered).to have_no_css 'script'
      expect(rendered).to have_css 'dd em', text: 'ok'
    end
  end

  describe '.values' do
    let(:value) { %W[<p>stuff</p> hello\nworld] }

    it 'returns the split and sanitized values (used by e.g. the JSON API)' do
      expect(described_class.values(field_config, document)).to eq %w(<p>stuff</p> hello world)
      expect(described_class.values(field_config, document)).to all(be_html_safe)
    end
  end

  describe '.split_on_white_space' do
    let(:value) { [] }
    let(:values) do
      ["Tariffs and Trade.\r\n\r\nThe purpose ofGATT secretariat.\r\n\r\nThe Bibliography"]
    end

    it 'splits values on embedded whitespace (based off of bc777tp9978)' do
      expect(described_class.split_on_white_space(values).length).to eq 5
    end
  end
end
