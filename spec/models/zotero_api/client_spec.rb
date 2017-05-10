require 'rails_helper'

describe ZoteroApi::Client do
  include ResponseFixtures
  subject { described_class.new id: 'abc', type: :user }
  before do
    allow(subject).to receive(:api_items).with(0).and_return(zotero_api_response)
    allow(subject).to receive(:api_items).with(zotero_api_response.length).and_return([])
  end
  describe '#bibliography' do
    it 'calls fetch_bibliography when @index is not present' do
      expect(subject).to receive(:fetch_bibliography)
      subject.bibliography
    end
    it 'does not call fetch_bibliography after it is already called' do
      expect(subject).to receive(:fetch_bibliography).once.and_return([])
      5.times { subject.bibliography }
    end
    it 'returns a data structure with druids as keys' do
      expect(subject.bibliography.keys.sort).to eq(%w(aa111bb2222 cc333dd4444 ee555ff6666))
    end
    it 'each item in bibliography is a ZoteroApi::Bibliography' do
      subject.bibliography.values.each do |value|
        expect(value).to be_a ZoteroApi::Bibliography
      end
    end
    it 'each ZoteroApi::Bibliography contains ZoteroApi::BibliographyItem' do
      subject.bibliography.values.each do |value|
        value.each do |item|
          expect(item).to be_a ZoteroApi::BibliographyItem
        end
      end
    end
  end
  describe '#bibliography_for' do
    describe 'provides an accessor by a druid' do
      context 'when present' do
        it { expect(subject.bibliography_for('aa111bb2222')).to be_a ZoteroApi::Bibliography }
      end
      context 'when absent' do
        it { expect(subject.bibliography_for('yolo')).to be_nil }
      end
    end
    it 'provides sorted ZoteroApi::Bibliography' do
      first = subject.bibliography_for('ee555ff6666').first
      expect(first.author).to eq 'Doe, Jane'
      expect(first.date).to eq 2001
    end
    context 'with no author present' do
      it 'author is empty' do
        first = subject.bibliography_for('cc333dd4444').first
        expect(first.author).to eq ''
        expect(first.date).to eq 1988
      end
    end
  end
end
