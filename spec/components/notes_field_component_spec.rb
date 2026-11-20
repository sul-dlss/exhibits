# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotesFieldComponent, type: :component do
  subject(:rendered) { render_inline(described_class.new(field:)) }

  let(:document) { SolrDocument.new(id: 'abc123', general_notes_ssim: notes) }
  let(:field_config) { CatalogController.blacklight_config.index_fields['general_notes_ssim'] }
  let(:field) { Blacklight::FieldPresenter.new(vc_test_controller.view_context, document, field_config) }

  before do
    allow(field).to receive(:render_field?).and_return(true)
  end

  context 'with multiple notes' do
    let(:notes) { %w(a <p>b</p><p>c</p> d) }

    it 'permits embedded HTML and handles multivalued notes as an unordered list' do
      expect(rendered.css('dd').inner_html)
        .to eq '<ul class="general-notes"><li>a</li><li><p>b</p><p>c</p></li><li>d</li></ul>'
    end
  end

  context 'with a single note' do
    let(:notes) { %w(stuff) }

    it 'renders the note' do
      expect(rendered.css('dd').text).to eq 'stuff'
      expect(rendered).to have_no_css 'ul.general-notes'
    end
  end

  context 'without notes' do
    let(:notes) { [] }

    it 'renders nothing' do
      expect(rendered.to_html).to be_blank
    end
  end
end
