# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PurlVirtualObject do
  subject(:virtual_object) { described_class.new(public_cocina:) }

  let(:public_cocina) do
    JSON.parse(File.read(File.join(FIXTURES_PATH, 'ws947mh3822.json')))
  end

  before do
    stub_request(:get, 'https://purl.stanford.edu/ts786ny5936.json').to_return(
      body: File.new(File.join(FIXTURES_PATH, 'ts786ny5936.json')), status: 200
    )
  end

  describe '#virtual_object?' do
    it 'returns true for a virtual object' do
      expect(virtual_object.virtual_object?).to be true
    end

    describe 'when the object is not virtual' do
      let(:public_cocina) do
        JSON.parse(File.read(File.join(FIXTURES_PATH, 'kj040zn0537.json')))
      end

      it 'returns false for a non-virtual object' do
        expect(virtual_object.virtual_object?).to be false
      end
    end
  end

  describe '#virtual_object_thumbnail_identifier' do
    it 'returns the thumbnail identifier for the first member of the virtual object' do
      expect(virtual_object.virtual_object_thumbnail_identifier).to eq(
        'https://stacks.stanford.edu/image/iiif/ts786ny5936%2FPC0170_s1_E_0204'
      )
    end

    describe 'when the object is not virtual' do
      let(:public_cocina) do
        JSON.parse(File.read(File.join(FIXTURES_PATH, 'kj040zn0537.json')))
      end

      it 'returns nil if there are no members' do
        expect(virtual_object.virtual_object_thumbnail_identifier).to be_nil
      end
    end
  end
end
