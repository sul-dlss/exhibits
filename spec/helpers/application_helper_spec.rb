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
    context 'single note' do
      it 'returns the note' do
        expect(helper.notes_wrap(value: %w(<p>stuff</p>))).to eq '<p>stuff</p>'
      end
    end
  end

  describe '#manuscript_title' do
    it 'adds basic support of display label' do
      expect(helper.manuscript_title(value: ['Label-|-Stuff'])).to eq 'Label - Stuff'
    end
  end

  describe '#table_of_contents_separator' do
    before { @document = SolrDocument.new(id: 'cf386wt1778') }
    let(:input) { { value: ['Homiliae--euangelia'] } }

    it 'separates MODS table of contents' do
      expect(helper.table_of_contents_separator(input)).to match(%r{Homiliae<br \/>euangelia})
    end

    it 'collapses content' do
      expect(helper.table_of_contents_separator(input)).to match(/data-toggle='collapse'/)
    end
  end
end
