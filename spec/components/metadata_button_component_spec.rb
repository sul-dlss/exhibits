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

  context 'when cocina metadata display is enabled' do
    before do
      allow(Settings.cocina).to receive(:metadata_display_source).and_return(true)
    end

    context 'when document is a dor resource' do
      let(:document) { SolrDocument.new(id: 'abc', spotlight_resource_type_ssim: ['dor_harvesters']) }

      it 'displays the metadata button' do
        expect(rendered).to have_css 'a', text: 'More details »'
      end
    end

    context 'when document is not a dor resource' do
      let(:document) { SolrDocument.new(id: 'abc') }

      it 'does not display the metadata button' do
        expect(rendered).not_to have_css 'a', text: 'More details »'
      end
    end
  end
end
