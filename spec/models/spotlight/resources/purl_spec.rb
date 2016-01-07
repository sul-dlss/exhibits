require 'spec_helper'

describe Spotlight::Resources::Purl do
  let :exhibit do
    double(solr_data: {}, blacklight_config: Blacklight::Configuration.new)
  end
  let :blacklight_solr do
    double
  end

  subject { described_class.new url: 'http://purl.stanford.edu/xf680rd3068' }

  before do
    allow(subject).to receive(:exhibit).and_return(exhibit)
    allow(subject).to receive(:blacklight_solr).and_return(blacklight_solr)
    allow(subject).to receive(:to_global_id).and_return('x')
  end

  describe '.can_provide?' do
    subject { described_class }
    it 'is true for a PURL URL' do
      expect(subject.can_provide?(double(url: 'https://purl.stanford.edu/xyz'))).to eq true
      expect(subject.can_provide?(double(url: 'http://purl.stanford.edu/xyz'))).to eq true
    end

    it 'is false other URLs' do
      expect(subject.can_provide?(double(url: 'https://example.com/xyz'))).to eq false
    end
  end

  describe '#doc_id' do
    it 'extracts DRUIDs from a PURL url' do
      subject.url = 'http://purl.stanford.edu/xyz'
      expect(subject.doc_id).to eq 'xyz'
    end

    it 'extracts DRUIDs from a PURL format url' do
      subject.url = 'http://purl.stanford.edu/xf680rd3068.xml'
      expect(subject.doc_id).to eq 'xf680rd3068'
    end

    it "extracts DRUIDs from a PURL's viewer url" do
      subject.url = 'http://purl.stanford.edu/xf680rd3068#image/1/small'
      expect(subject.doc_id).to eq 'xf680rd3068'
    end
  end

  describe '#resource' do
    it 'is a Harvestdor::Indexer resource' do
      expect(subject.resource).to be_a_kind_of Harvestdor::Indexer::Resource
    end

    it 'has the correct druid' do
      expect(subject.resource.druid).to eq 'xf680rd3068'
    end

    it 'has the correct indexer' do
      expect(subject.resource.indexer).to eq Spotlight::Dor::Resources.indexer.harvestdor
    end
  end

  describe '#reindex' do
    before do
      allow(Spotlight::Dor::Resources.indexer).to receive(:solr_document).and_return(upstream: true)
      allow(subject.resource).to receive(:collection?).and_return(false)
    end

    it 'adds a document to solr' do
      solr_data = [{ spotlight_resource_id_ssim: subject.to_global_id,
                     spotlight_resource_type_ssim: 'spotlight/resources/purls',
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
        allow(subject.resource).to receive(:collection?).and_return(true)
      end

      it 'provides a solr document for the collection' do
        allow(subject.resource).to receive(:items).and_return([])
        expect(Spotlight::Dor::Resources.indexer).to receive(:solr_document).with(subject.resource).and_return(upstream: true)
        expect(subject.to_solr.first).to include :upstream, :spotlight_resource_id_ssim, :spotlight_resource_type_ssim
      end

      it 'provides a solr document for the items too' do
        item = double(druid: 'xyz')
        allow(subject.resource).to receive(:items).and_return([item])
        expect(Spotlight::Dor::Resources.indexer).to receive(:solr_document).with(subject.resource).and_return(collection: true)
        expect(Spotlight::Dor::Resources.indexer).to receive(:solr_document).with(item).and_return(item: true)
        solr_doc = subject.to_solr.to_a
        expect(solr_doc.first).to include :collection
        expect(solr_doc.last).to include :item
      end

      it 'traps indexing errors' do
        allow(subject.resource).to receive(:items).and_return([])
        expect(Spotlight::Dor::Resources.indexer).to receive(:solr_document).and_raise(RuntimeError.new)
        expect { subject.to_solr.to_a }.not_to raise_error
      end

      it 'log and raises other types of errors errors' do
        allow(subject.resource).to receive(:items).and_return([])
        expect(Spotlight::Dor::Resources.indexer).to receive(:solr_document).and_raise(StandardError.new)
        expect(subject.send(:logger)).to receive(:error).with(/Error processing xf680rd3068/)
        expect { subject.to_solr.to_a }.to raise_error StandardError
      end
    end

    context 'with a single item' do
      it 'provides a solr document for the resource' do
        allow(subject.resource).to receive(:collection?).and_return(false)
        expect(Spotlight::Dor::Resources.indexer).to receive(:solr_document).with(subject.resource).and_return(upstream: true)
        expect(subject.to_solr.first).to include :upstream, :spotlight_resource_id_ssim, :spotlight_resource_type_ssim
      end
    end
  end
end
