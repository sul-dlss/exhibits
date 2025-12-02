# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MetadataButtonComponent, type: :component do
  subject(:rendered) do
    Capybara::Node::Simple.new(render_inline(described_class.new(exhibit:, document:)).to_s)
  end

  let(:document) { SolrDocument.new(modsxml: '<mods></mods>', id: 'abc') }
  let(:exhibit) { create(:exhibit) }

  context 'when modsxml is available' do
    it 'has displays metadata button' do
      expect(rendered).to have_css 'a', text: 'More details »'
    end
  end

  context 'when modsxml is missing' do
    let(:document) { SolrDocument.new }

    it 'does not display the metadata button' do
      expect(rendered).not_to have_css 'a', text: 'More details »'
    end
  end
end
