# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metadata::ModsComponent, type: :component do
  subject(:rendered) do
    render_inline(described_class.new(document: document)).to_html
  end

  let(:document) { SolrDocument.new }
  let(:modsxml) { File.read(File.join(FIXTURES_PATH, 'mods/bb099mt5053.xml')) }

  context 'when the document has MODS XML' do
    before do
      allow(document).to receive(:modsxml).and_return(modsxml)
    end

    it 'renders the component' do
      expect(rendered).not_to be_empty
    end

    it 'includes specific metadata sections' do
      expect(rendered).to have_css 'h4', text: 'Access conditions'
      expect(rendered).to have_css 'h4', text: 'Description'
      expect(rendered).to have_css 'h4', text: 'Creators/Contributors'
    end

    it 'includes metadata field values' do
      expect(rendered).to have_css 'dd', text: 'Wong, Martin'
      expect(rendered).to have_css 'dd', text: 'Patty Hearst'
      expect(rendered).to have_css 'dd', text: 'Digital image held by the Stanford Libraries.'
    end
  end

  context 'when the document does not have MODS XML' do
    before do
      allow(document).to receive(:modsxml).and_return(nil)
    end

    it 'does not render the component' do
      expect(rendered).to be_empty
    end
  end
end
