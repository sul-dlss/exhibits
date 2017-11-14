# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IiifManifestHarvester do
  subject { described_class.new(mani_url) }

  let(:mani_url) { 'http://example.org/iiif/book1/manifest' }
  let(:mani_file) { 'spec/fixtures/iiif/book1.json' }

  before do
    allow(Faraday).to receive(:get).with(mani_url).and_return(
      instance_double(Faraday::Response, body: File.read(mani_file))
    )
  end

  describe '#manifest' do
    it 'is a parsed IIIF::Presentation::Manifest' do
      expect(subject.manifest).to be_an IIIF::Presentation::Manifest
    end
  end
  describe '#canvases' do
    it 'returns the first sequence canvases' do
      expect(subject.canvases.count).to eq 3
      expect(subject.canvases).to all(be_an(IIIF::Presentation::Canvas))
    end
  end

  describe '#ranges_for' do
    it 'is an array of range objects that include the given canvas id' do
      ranges = subject.ranges_for('http://example.org/iiif/book1/canvas/p2')
      expect(ranges.length).to eq 2
      expect(ranges).to all(be_an(IIIF::Presentation::Range))
      expect(ranges.first['@id']).to eq 'http://example.org/iiif/book1/range/r1'
      expect(ranges.last['@id']).to eq 'http://example.org/iiif/book1/range/r1-1'
    end

    it 'gets the correct range even if the canvas ID in the range has a xywh defined' do
      ranges = subject.ranges_for('http://example.org/iiif/book1/canvas/p3')
      expect(ranges.length).to eq 1
      expect(ranges.first.canvases).not_to include 'http://example.org/iiif/book1/canvas/p3'
      expect(ranges.first.canvases).to include 'http://example.org/iiif/book1/canvas/p3#xywh=0,0,750,300'
    end

    it 'is an empty array when the given id does not exist' do
      expect(subject.ranges_for('non-existent-id')).to eq([])
    end
  end
end
