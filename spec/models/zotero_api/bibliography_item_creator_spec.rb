require 'rails_helper'

describe ZoteroApi::BibliographyItemCreator do
  include ResponseFixtures
  describe '#formatted_author' do
    let(:full_author) { zotero_api_response.first.with_indifferent_access.fetch('data').fetch('creators').first }
    let(:no_author) { zotero_api_response[6].with_indifferent_access.fetch('data').fetch('creators').first }
    let(:partial_author) { zotero_api_response[7].with_indifferent_access.fetch('data').fetch('creators').first }
    context 'with full author' do
      it do
        expect(described_class.new(full_author).formatted_author).to eq 'Doe, John'
      end
    end
    context 'with no author' do
      it do
        expect(described_class.new(no_author).formatted_author).to eq ''
      end
    end
    context 'with partial author' do
      it do
        expect(described_class.new(partial_author).formatted_author).to eq 'The Artist'
      end
    end
  end
end
