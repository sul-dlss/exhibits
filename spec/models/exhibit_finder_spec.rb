# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExhibitFinder do
  let(:finder) { described_class.new(document_id) }

  describe '.find' do
    it 'is a JsonResponse for the found exhibit(s)' do
      exhibit = create(:exhibit, slug: 'default-exhibit')
      found = described_class.find('hj066rn6500')

      expect(found).to be_an ExhibitFinder::JsonResponse
      expect(found.as_json).to include(
        hash_including(
          'id' => exhibit.id,
          'title' => exhibit.title,
          'slug' => exhibit.slug
        )
      )
    end
  end

  describe '.search' do
    let(:exhibit) { create(:exhibit) }
    let(:solr_connection) { instance_double('Blacklighgt::Solr::Connection') }

    before do
      allow(Blacklight.default_index).to receive_messages(connection: solr_connection)
    end

    it 'is a JSONResponse for the documents queried from the index' do
      allow(solr_connection).to receive(:select).and_return(
        'response' => { 'docs' => [{ 'exhibit_slug_ssi' => exhibit.slug }] }
      )
      search = described_class.search('Exhib')
      expect(search).to be_an ExhibitFinder::JsonResponse
      expect(search.as_json).to include(
        hash_including(
          'id' => exhibit.id, 'title' => exhibit.title, 'slug' => exhibit.slug
        )
      )
    end

    it 'sends in a query that ORs itself and a wildcarded version of itself' do
      allow(solr_connection).to receive(:select).with(
        params: hash_including(
          q: '(Exhib) OR (Exhib*)'
        )
      ).and_return({})

      described_class.search('Exhib')
    end
  end

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
        allow(Settings).to receive_messages(nondiscoverable_exhibit_slugs: [published_exhibit.slug])
      end

      it { expect(finder.exhibits.map(&:id)).to be_blank }
    end
  end

  describe ExhibitFinder::JsonResponse do
    let(:json_response) { described_class.new([exhibit]) }
    let(:exhibit) { create(:exhibit, :with_thumbnail) }

    it 'returns the exhibit json representation' do
      expect(json_response.as_json.length).to eq 1
      expect(json_response.as_json.first).to be_a Hash
      expect(json_response.as_json.first['id']).to eq exhibit.id
    end

    it 'injects a thumbnail_url attribute into the json representation' do
      expect(json_response.as_json.first['thumbnail_url']).to match(
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
