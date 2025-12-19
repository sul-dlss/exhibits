# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PurlThumbnail do
  let(:purl_object) { Purl.new('druid:kj040zn0537') }

  before do
    stub_request(:get, 'https://purl.stanford.edu/kj040zn0537.json').to_return(
      body: File.new(File.join(FIXTURES_PATH, 'cocina/kj040zn0537.json')),
      status: 200
    )
  end

  describe '#thumbnail_identifier' do
    let(:thumbnail_service) { described_class.new(purl_object: purl_object) }

    it 'returns the thumbnail identifier URL' do
      expect(thumbnail_service.thumbnail_identifier).to eq(
        'https://stacks.stanford.edu/image/iiif/kj040zn0537%2FT0000001'
      )
    end
  end
end
