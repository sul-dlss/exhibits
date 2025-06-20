# frozen_string_literal: true

require 'rails_helper'

describe PurlCollections do
  subject(:purl_collections) { described_class.call(public_cocina) }

  let(:public_cocina) { JSON.parse(File.read(File.join(FIXTURES_PATH, 'cc842mn9348.json'))) }

  describe '.call' do
    it 'returns an array of Purl objects for the collections this Purl belongs to' do
      expect(purl_collections).to be_an(Array)
      expect(purl_collections.first).to be_a(Purl)
      expect(purl_collections.first.druid).to eq('kh392jb5994')
    end
  end
end
