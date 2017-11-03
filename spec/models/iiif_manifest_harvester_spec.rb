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
end
