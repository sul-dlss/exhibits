# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IiifCanvasIndexer do
  include ActiveJob::TestHelper
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
      iiif_manifest_url_ssi: 'http://example.com',
      identifier_ssim: %w(ABC 123 xyz)
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

  describe '#index_canvases' do
    it 'creates CanvasResource objects for otherContent annotationLists' do
      expect do
        subject.index_canvases
      end.to change { CanvasResource.count }.from(0).to(3)
    end

    it 'stores the JSON of the canvas in the CanvasResource' do
      subject.index_canvases
      expect(CanvasResource.first.data['@id']).to eq 'http://example.org/iiif/book1/canvas/p1'
      expect(CanvasResource.last.data['@id']).to eq 'http://example.org/iiif/book1/canvas/p3'
    end

    it 'enhances the JSON of the canvas with additional needed fields' do
      subject.index_canvases
      expect(CanvasResource.first.data['manifest_label']).to eq 'Book 1'
      expect(CanvasResource.first.data['parent_identifier']).to eq(%w(ABC 123 xyz))
    end

    it 'enqueues the same number of jobs as otherContent annotationLists' do
      expect do
        subject.index_canvases
      end.to change { enqueued_jobs.count }.by(3)
    end

    context 'when not a image thing' do
      let(:document) { SolrDocument.new(id: druid) }

      it 'does not create any CanvaseResources or enqueues any jobs' do
        expect do
          subject.index_canvases
        end.not_to(change { CanvasResource.count })

        expect do
          subject.index_canvases
        end.not_to(change { enqueued_jobs.count })
      end
    end
  end
end
