# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExhibitFinder do
  let(:finder) { described_class.new(document_id) }

  describe '#exhibits' do
    let(:document_id) { 'abc123' }
    let(:published_exhibit) { create(:exhibit) }
    let(:published_exhibit2) { create(:exhibit) }
    let(:unpublished_exhibit) { create(:exhibit, published: false) }
    let(:public_document) do
      SolrDocument.new(
        id: 'abc123',
        spotlight_exhibit_slugs_ssim: [published_exhibit.slug, unpublished_exhibit.slug],
        "exhibit_#{published_exhibit.slug}_public_bsi": [true],
        "exhibit_#{unpublished_exhibit.slug}_public_bsi": [true]
      )
    end
    let(:private_document) do
      SolrDocument.new(
        id: 'abc123',
        spotlight_exhibit_slugs_ssim: [published_exhibit.slug],
        "exhibit_#{published_exhibit.slug}_public_bsi": [false]
      )
    end
    let(:mixed_privacy_document) do
      SolrDocument.new(
        id: 'abc123',
        spotlight_exhibit_slugs_ssim: [published_exhibit.slug, published_exhibit2.slug],
        "exhibit_#{published_exhibit.slug}_public_bsi": [false],
        "exhibit_#{published_exhibit2.slug}_public_bsi": [true]
      )
    end

    context 'with a public document' do
      before do
        allow(finder).to receive_messages(documents: [public_document])
      end

      it { expect(finder.exhibits.map(&:id)).to eq [published_exhibit.id] }
      it { expect(finder.exhibits.map(&:id)).not_to include(unpublished_exhibit.id) } # Effectively asserted above too
    end

    context 'with a private document' do
      before do
        allow(finder).to receive_messages(documents: [private_document])
      end

      it { expect(finder.exhibits.map(&:id)).to be_blank }
    end

    context 'when a document is private in an exhibit' do
      before do
        allow(finder).to receive_messages(documents: [mixed_privacy_document])
      end

      it { expect(finder.exhibits.map(&:id)).to eq [published_exhibit2.id] }
      it { expect(finder.exhibits.map(&:id)).not_to include(published_exhibit.id) } # Effectively asserted above too
    end

    context 'when an exhibit is blacklisted from discoverability' do
      before do
        allow(finder).to receive_messages(documents: [public_document])
        allow(Settings).to receive_messages(discoverable_exhibit_slugs_blacklist: [published_exhibit.slug])
      end

      it { expect(finder.exhibits.map(&:id)).to be_blank }
    end
  end

  describe '#as_json' do
    let(:document_id) { 'abc123' }
    let(:exhibit) { create(:exhibit, :with_thumbnail) }
    let(:document) do
      SolrDocument.new(
        id: 'abc123',
        spotlight_exhibit_slugs_ssim: [exhibit.slug],
        "exhibit_#{exhibit.slug}_public_bsi": [true]
      )
    end

    before do
      allow(finder).to receive_messages(documents: [document])
    end

    it 'returns the exhibit json representation' do
      expect(finder.as_json.length).to eq 1
      expect(finder.as_json.first).to be_a Hash
      expect(finder.as_json.first['id']).to eq exhibit.id
    end

    it 'injects a thumbnail_url attribute into the json representation' do
      expect(finder.as_json.first['thumbnail_url']).to match(
        %r{stanford\.edu/images/\d+/full/400,400/0/default.jpg}
      )
    end
  end

  describe '#documents (private)' do
    let(:documents) { finder.send(:documents) }

    context 'with a document id druid' do
      let(:document_id) { 'wr055hy7401' }

      it 'returns the appropriate document' do
        expect(documents.length).to eq 1
        expect(documents.first['id']).to eq 'wr055hy7401'
      end
    end

    context 'with a collection druid' do
      let(:document_id) { 'ct961sj2730' }

      it 'returns the appropriate document' do
        expect(documents.length).to eq 13
        expect(documents.first['id']).to eq 'hj066rn6500' # A document in the collection ct961sj2730
      end
    end
  end
end
