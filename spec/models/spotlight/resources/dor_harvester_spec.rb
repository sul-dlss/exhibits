require 'spec_helper'

describe Spotlight::Resources::DorHarvester do
  let(:exhibit) { FactoryGirl.create(:exhibit) }

  let :blacklight_solr do
    double
  end

  subject { described_class.new druid_list: 'xf680rd3068', exhibit: exhibit }
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

    context 'with an unpublished druid' do
      let(:missing_resource) { instance_double(Harvestdor::Indexer::Resource, exists?: false) }

      before do
        allow(Spotlight::Dor::Resources.indexer).to receive(:resource).with('xf680rd3068').and_return(missing_resource)
      end

      it 'excludes missing resources' do
        expect(subject.resources).to be_empty
      end
    end
  end

  describe '#reindex' do
    before do
      allow(Spotlight::Dor::Resources.indexer).to receive(:solr_document).and_return(upstream: true)
      allow(resource).to receive(:collection?).and_return(false)
      allow_any_instance_of(SolrDocument).to receive(:to_solr).and_return({})
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
end
