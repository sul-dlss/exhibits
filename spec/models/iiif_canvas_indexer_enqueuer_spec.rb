# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IiifCanvasIndexerEnqueuer do
  subject { described_class.new(exhibit, druid) }

  let(:viewer) do
    FactoryGirl.create(
      :viewer,
      custom_manifest_pattern: 'http://example.org/iiif/{id}/manifest'
    )
  end
  let(:exhibit) { FactoryGirl.create(:exhibit, viewer: viewer) }
  let(:druid) { 'book1' }
  let(:document) do
    SolrDocument.new(
      id: druid,
      content_metadata_type_ssm: ['image'],
      iiif_manifest_url_ssi: 'http://example.com'
    )
  end
  let(:mani_url) { 'http://example.org/iiif/book1/manifest' }
  let(:mani_file) { 'spec/fixtures/iiif/book1.json' }

  before do
    allow(Faraday).to receive(:get).with(mani_url).and_return(
      instance_double(Faraday::Response, body: File.read(mani_file))
    )
    allow(SolrDocument).to receive(:find).with(druid).and_return(document)
  end

  describe '#enqueue_jobs' do
    it 'enqueues the same number of jobs as otherContent annotationLists' do
      subject.enqueue_jobs
      expect(IndexCanvasJob).to have_been_enqueued.exactly(3).times
    end
    context 'when not a image thing' do
      let(:document) { SolrDocument.new(id: druid) }

      it 'does not enqueue anything' do
        subject.enqueue_jobs
        expect(IndexCanvasJob).not_to have_been_enqueued
      end
    end
  end
end
