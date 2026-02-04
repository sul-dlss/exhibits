# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Purl do
  subject(:purl) { described_class.new(druid) }

  let(:druid) { 'kj040zn0537' }

  before do
    stub_request(:get, "https://purl.stanford.edu/#{druid}.json").to_return(
      body: File.new(File.join(FIXTURES_PATH, "cocina/#{druid}.json")), status: 200
    )
  end

  describe '#collections' do
    subject(:collections) { purl.collections }

    it 'returns an array of Purls for collections that include this item' do
      expect(collections).to be_an(Array)
      expect(collections.first).to be_a(described_class)
      expect(collections.first.druid).to eq('jh957jy1101')
    end
  end

  describe '#collection?' do
    subject(:collection?) { purl.collection? }

    context 'when the Purl is a collection' do
      let(:druid) { 'gh795jd5965' }

      it 'returns true' do
        expect(collection?).to be true
      end
    end

    it 'when the Purl is not a collection it returns false' do
      expect(collection?).to be false
    end
  end

  describe '#collection_member_druids' do
    subject(:collection_member_druids) { purl.collection_member_druids }

    let(:purl_fetcher_client) { instance_double(PurlFetcher::Client::Reader) }

    before do
      allow(PurlFetcher::Client::Reader).to receive(:new).and_return(purl_fetcher_client)
      allow(purl_fetcher_client).to receive(:collection_members).with(druid).and_return([{ 'druid' => 'kj040zn0537' }])
    end

    context 'when the Purl is a collection' do
      let(:druid) { 'gh795jd5965' }

      it 'returns an array of member druids' do
        expect(collection_member_druids).to eq(['kj040zn0537'])
      end
    end

    it 'when the Purl is not a collection it returns an empty array' do
      expect(collection_member_druids).to eq([])
    end
  end

  describe '#bare_druid' do
    it 'returns the druid without the "druid:" prefix' do
      expect(purl.bare_druid).to eq('kj040zn0537')
    end
  end

  describe '#cocina_record' do
    before do
      stub_request(:get, "https://purl.stanford.edu/#{druid}.json").to_return(
        body: File.new(File.join(FIXTURES_PATH, "/cocina/#{druid}.json")), status: 200
      )
    end

    it 'returns a CocinaDisplay::CocinaRecord object' do
      expect(purl.cocina_record).to be_a(CocinaDisplay::CocinaRecord)
    end
  end
end
