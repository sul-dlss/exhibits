require 'rails_helper'

describe DorSolrDocumentBuilder do
  let(:exhibit) { FactoryGirl.create(:exhibit) }

  let :blacklight_solr do
    double
  end

  subject { described_class.new harvester }
  let(:harvester) { DorHarvester.new druid_list: 'xf680rd3068', exhibit: exhibit }

  before do
    allow(harvester).to receive(:blacklight_solr).and_return(blacklight_solr)
    allow(harvester).to receive(:to_global_id).and_return('x')
  end

  let(:resource) { harvester.resources.first }
  let(:indexer) { Spotlight::Dor::Resources.indexer }

  describe '#to_solr' do
    before do
      allow(indexer).to receive(:solr_document)
    end

    context 'with a collection' do
      before do
        allow(resource).to receive(:collection?).and_return(true)
      end

      it 'provides a solr document for the collection' do
        allow(resource).to receive(:items).and_return([])
        expect(indexer).to receive(:solr_document).with(resource).and_return(upstream: true)
        expect(subject.to_solr.first).to include :upstream, :spotlight_resource_id_ssim, :spotlight_resource_type_ssim
      end

      context 'with items' do
        let(:item) { instance_double('Harvestdor::Indexer::Resource', druid: 'xyz') }

        before do
          allow(resource).to receive(:items).and_return([item])
        end

        it 'provides a solr document for the items too' do
          expect(indexer).to receive(:solr_document).with(resource).and_return(collection: true)
          expect(indexer).to receive(:solr_document).with(item).and_return(item: true)
          solr_doc = subject.to_solr.to_a
          expect(solr_doc.first).to include :collection
          expect(solr_doc.last).to include :item
        end
      end

      it 'traps indexing errors' do
        allow(resource).to receive(:items).and_return([])
        expect(indexer).to receive(:solr_document).and_raise(RuntimeError.new)
        expect { subject.to_solr.to_a }.not_to raise_error
      end

      it 'log and raises other types of errors errors' do
        allow(resource).to receive(:items).and_return([])
        expect(indexer).to receive(:solr_document).and_raise(StandardError.new)
        expect(subject.send(:logger)).to receive(:error).with(/Error processing xf680rd3068/)
        expect { subject.to_solr.to_a }.to raise_error StandardError
      end
    end

    context 'with a single item' do
      it 'provides a solr document for the resource' do
        allow(resource).to receive(:collection?).and_return(false)
        expect(indexer).to receive(:solr_document).with(resource).and_return(upstream: true)
        expect(subject.to_solr.first).to include :upstream, :spotlight_resource_id_ssim, :spotlight_resource_type_ssim
      end
    end
  end
end
