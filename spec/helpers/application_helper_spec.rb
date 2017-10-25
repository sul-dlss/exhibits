require 'rails_helper'

describe ApplicationHelper, type: :helper do
  describe '#collection_title' do
    it 'unmangles the collection title from the compound field' do
      expect(helper.collection_title('foo-|-bar')).to eq 'bar'
    end
  end

  describe '#collection_title_for_index_field' do
    it 'unmangles the collection title from the compound field' do
      expect(helper.document_collection_title(value: 'foo-|-bar')).to eq 'bar'
    end

    it 'handles multivalued fields' do
      expect(helper.document_collection_title(value: ['foo-|-bar', 'baz-|-bop'])).to eq 'bar and bop'
    end
  end

  describe '#notes_wrap' do
    let(:output) { '<ul class="general-notes"><li>a</li><li><p>b</p><p>c</p></li><li>d</li></ul>' }

    it 'permits embedded HTML and handles multivalued notes as an unordered list' do
      expect(helper.notes_wrap(value: %w(a <p>b</p><p>c</p> d))).to eq output
    end
  end

  describe '#manuscript_title' do
    it 'adds basic support of display label' do
      expect(helper.manuscript_title(value: ['Label-|-Stuff'])).to eq 'Label - Stuff'
    end
  end

  describe '#labeled_mods_notes' do
    it 'parses notes displayLabel and text' do
      expect(helper.labeled_mods_notes(value: ['Material-|-Vellum'])).to eq '<dt>Material</dt><dd>Vellum</dd>'
    end
  end
end
