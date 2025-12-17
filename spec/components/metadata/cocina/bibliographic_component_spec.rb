# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Metadata::Cocina::BibliographicComponent, type: :component do
  subject(:rendered) do
    render_inline(described_class.new(cocina_record:)).to_html
  end

  let(:cocina_record) do
    CocinaDisplay::CocinaRecord.new(JSON.parse(File.read(File.join(FIXTURES_PATH, "/cocina/#{druid}.json"))))
  end
  let(:druid) { 'hp566jq8781' }

  context 'when the record has multiple nested related resources' do
    it 'renders the related resources using nested presentation' do
      expect(rendered).to have_css 'h4', text: 'Bibliographic information'
      expect(rendered).to have_css 'dt', text: 'Contains'
      expect(rendered).to have_css 'dt button', text: 'Expand all'
      within 'dd details' do
        expect(rendered).to have_css 'dl dt', text: 'Nasmith'
        expect(rendered).to have_css 'dl dd', text: 'Epitome chronicae Cicestrensis, sed extractum ' \
                                                    'e Polychronico, usque ad annum Christi 1429. 1r-29v'
      end
    end
  end

  context 'when the record has a related resource with a labeled URL' do
    let(:druid) { 'vc287zp9960' }

    it 'renders the related resource as a labeled link' do
      expect(rendered).to have_css 'h4', text: 'Bibliographic information'
      expect(rendered).to have_css 'dt', text: 'Related item'
      expect(rendered).to have_link text: 'Link to SearchWorks record for conserved item',
                                    href: 'https://searchworks.stanford.edu/view/513014'
    end
  end

  context 'when the record has related resources with a single value' do
    let(:druid) { 'hm136qv0310' }

    it 'renders the related resource without nesting' do
      expect(rendered).to have_css 'h4', text: 'Bibliographic information'
      expect(rendered).to have_css 'dt', text: 'Part of'
      expect(rendered).to have_css 'dd', text: 'Bibliographie de Manon Lescaut: ' \
                                               "et notes pour servir a l'histoire du livre"
    end
  end
end
