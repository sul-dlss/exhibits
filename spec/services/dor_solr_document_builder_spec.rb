# frozen_string_literal: true

require 'rails_helper'

describe DorSolrDocumentBuilder do
  subject { described_class.new harvester }

  let(:exhibit) { create(:exhibit) }
  let(:druid) { 'xf680rd3068' }
  let(:harvester) { DorHarvester.new druid_list: druid, exhibit: exhibit }
  let(:resources) { [resource].to_enum }
  let(:resource) { Harvestdor::Indexer::Resource.new(nil, druid) }

  before do
    allow(resource).to receive(:exists?).and_return(true)
    allow(harvester).to receive(:resources).and_return(resources)
    allow(harvester).to receive(:blacklight_solr).and_return(double)
    allow(harvester).to receive(:to_global_id).and_return('x')
    allow_any_instance_of(Traject::Indexer).to receive(:map_record).and_return('upstream' => true)
  end

  describe '#to_solr' do
    let(:logger) { subject.send(:logger) }

    context 'with a collection' do
      before do
        allow(resource).to receive(:collection?).and_return(true)
      end

      it 'provides a solr document for the collection' do
        allow(resource).to receive(:items).and_return([])
        expect(subject.to_solr.first).to include :upstream, :spotlight_resource_id_ssim, :spotlight_resource_type_ssim
      end

      context 'with items' do
        let(:item) { instance_double('Harvestdor::Indexer::Resource', druid: 'xyz', bare_druid: 'xyz') }

        before do
          allow(resource).to receive(:items).and_return([item])
        end

        it 'provides a solr document for the items too' do
          allow_any_instance_of(Traject::Indexer).to receive(:map_record).with(resource).and_return(collection: true)
          allow_any_instance_of(Traject::Indexer).to receive(:map_record).with(item).and_return(item: true)
          solr_doc = subject.to_solr.to_a
          expect(solr_doc.first).to include :collection
          expect(solr_doc.last).to include :item
        end
      end

      it 'traps indexing errors' do
        allow(resource).to receive(:items).and_return([])
        allow_any_instance_of(Traject::Indexer).to receive(:map_record).and_raise(StandardError.new)
        allow(logger).to receive(:error)
        expect { subject.to_solr.to_a }.not_to raise_error
        expect(logger).to have_received(:error).with(/Error processing xf680rd3068/)
      end
    end

    context 'with a single item' do
      it 'provides a solr document for the resource' do
        allow(resource).to receive(:collection?).and_return(false)
        expect(subject.to_solr.first).to include :upstream, :spotlight_resource_id_ssim, :spotlight_resource_type_ssim
      end
    end
  end
end
