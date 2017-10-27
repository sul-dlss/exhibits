# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Canvas resource integration test', type: :feature do
  subject(:document) { SolrDocument.new(to_solr_hash) }

  let(:resource) { CanvasResource.new(exhibit: exhibit, data: JSON.parse(File.read(file))) }
  let(:file) { 'spec/fixtures/iiif/fh878gz0315-canvas-521.json' }
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:to_solr_hash) { resource.document_builder.to_solr.first }
  let(:annolist_file) { 'spec/fixtures/iiif/fh878g0315-text-f254r.json' }
  let(:annolist_url) { 'https://dms-data.stanford.edu/data/manifests/Parker/fh878gz0315/list/text-f254r.json' }

  before :all do
    ActiveJob::Base.queue_adapter = :inline # block until indexing has committed
  end

  before do
    allow(Faraday).to receive(:get).with(annolist_url).and_return(
      instance_double(Faraday::Response, body: File.read(annolist_file))
    )
  end

  after :all do
    ActiveJob::Base.queue_adapter = :test # restore
  end

  it 'can write the document to solr' do
    expect { resource.reindex }.not_to raise_error
  end

  context 'to_solr' do
    subject(:canvas) { document.canvas }

    it 'has correct format' do
      expect(document['format_main_ssim']).to include 'Page'
    end

    it 'has canvas attributes' do
      expect(canvas.id).to eq 'canvas-0fa395980b05e493948e0e2b50debd42'
      expect(canvas.iiif_id).to eq 'https://dms-data.stanford.edu/data/manifests/Parker/fh878gz0315/canvas/canvas-521'
      expect(canvas.label).to eq 'f. 254 r'
    end

    it 'has canvas annotations' do
      expect(canvas.annotation_lists).to include annolist_url
      expect(canvas.annotations.size).to eq 30
      expect(canvas.annotations).to include 'scæððig wæs his fæder geoffrod for ure alysed'
    end
  end
end
