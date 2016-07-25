require 'spec_helper'

describe Spotlight::Resources::DorHarvester do
  let(:exhibit) { FactoryGirl.create(:exhibit) }

  let :blacklight_solr do
    double
  end

  subject { described_class.new druid_list: 'xf680rd3068' }
  let(:resource) { subject.resources.first }

  before do
    allow(subject).to receive(:exhibit).and_return(exhibit)
    allow(subject).to receive(:blacklight_solr).and_return(blacklight_solr)
    allow(subject).to receive(:to_global_id).and_return('x')
  end

  describe '.instance' do
    subject { described_class.instance(exhibit).tap(&:save) }
    it 'behaves like a singleton' do
      expect(described_class.instance(exhibit)).to eq subject
    end
  end

  describe '#druids' do
    context 'with a single item' do
      subject { described_class.new druid_list: 'xf680rd3068' }

      it 'extracts an array of DRUIDs from the list of druids' do
        expect(subject.druids).to match_array 'xf680rd3068'
      end
    end

    context 'with multiple items' do
      subject { described_class.new druid_list: "xf680rd3068\nxf680rd3069" }

      it 'extracts an array of DRUIDs from the list of druids' do
        expect(subject.druids).to match_array %w(xf680rd3068 xf680rd3069)
      end
    end

    context 'with crazy whitespace' do
      subject { described_class.new druid_list: "\t xf680rd3068\t\r\nxf680rd3067\t\t" }

      it 'extracts an array of DRUIDs from the list of druids' do
        expect(subject.druids).to match_array %w(xf680rd3068 xf680rd3067)
      end
    end
  end

  describe '#resources' do
    it 'is a Harvestdor::Indexer resource' do
      expect(resource).to be_a_kind_of Harvestdor::Indexer::Resource
    end

    it 'has the correct druid' do
      expect(resource.druid).to eq 'xf680rd3068'
    end

    it 'has the correct indexer' do
      expect(resource.indexer).to eq Spotlight::Dor::Resources.indexer.harvestdor
    end
  end

  describe '#reindex' do
    before do
      allow(Spotlight::Dor::Resources.indexer).to receive(:solr_document).and_return(upstream: true)
      allow(resource).to receive(:collection?).and_return(false)
      allow(exhibit).to receive(:solr_data).and_return({})
    end

    it 'adds a document to solr' do
      solr_data = [{ spotlight_resource_id_ssim: subject.to_global_id,
                     spotlight_resource_type_ssim: 'spotlight/resources/dor_harvesters',
                     upstream: true }]
      expect(blacklight_solr).to receive(:update).with(params: { commitWithin: 500 },
                                                       data: solr_data.to_json,
                                                       headers: { 'Content-Type' => 'application/json' })
      expect(subject).to receive(:commit)
      subject.reindex
    end
  end

  describe '#to_solr' do
    before do
      allow(Spotlight::Dor::Resources.indexer).to receive(:solr_document)
    end

    context 'with a collection' do
      before do
        allow(resource).to receive(:collection?).and_return(true)
      end

      it 'provides a solr document for the collection' do
        allow(resource).to receive(:items).and_return([])
        expect(Spotlight::Dor::Resources.indexer).to receive(:solr_document).with(resource).and_return(upstream: true)
        expect(subject.to_solr.first).to include :upstream, :spotlight_resource_id_ssim, :spotlight_resource_type_ssim
      end

      it 'provides a solr document for the items too' do
        item = double(druid: 'xyz')
        allow(resource).to receive(:items).and_return([item])
        expect(Spotlight::Dor::Resources.indexer).to receive(:solr_document).with(resource).and_return(collection: true)
        expect(Spotlight::Dor::Resources.indexer).to receive(:solr_document).with(item).and_return(item: true)
        solr_doc = subject.to_solr.to_a
        expect(solr_doc.first).to include :collection
        expect(solr_doc.last).to include :item
      end

      it 'traps indexing errors' do
        allow(resource).to receive(:items).and_return([])
        expect(Spotlight::Dor::Resources.indexer).to receive(:solr_document).and_raise(RuntimeError.new)
        expect { subject.to_solr.to_a }.not_to raise_error
      end

      it 'log and raises other types of errors errors' do
        allow(resource).to receive(:items).and_return([])
        expect(Spotlight::Dor::Resources.indexer).to receive(:solr_document).and_raise(StandardError.new)
        expect(subject.send(:logger)).to receive(:error).with(/Error processing xf680rd3068/)
        expect { subject.to_solr.to_a }.to raise_error StandardError
      end
    end

    context 'with a single item' do
      it 'provides a solr document for the resource' do
        allow(resource).to receive(:collection?).and_return(false)
        expect(Spotlight::Dor::Resources.indexer).to receive(:solr_document).with(resource).and_return(upstream: true)
        expect(subject.to_solr.first).to include :upstream, :spotlight_resource_id_ssim, :spotlight_resource_type_ssim
      end
    end
  end
end
