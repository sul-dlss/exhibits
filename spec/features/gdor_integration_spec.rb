require 'rails_helper'

RSpec.describe 'gdor indexing integration test', type: :feature do
  subject(:dor_harvester) { DorHarvester.new(druid_list: druid, exhibit: exhibit) }

  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:druid) { 'xf680rd3068' }

  before do
    stub_const('Harvestdor::PURL_DEFAULT', File.expand_path(File.join('..', '..', 'fixtures'), __FILE__))
  end

  it 'can write the document to solr' do
    dor_harvester.reindex
  end

  context 'to_solr' do
    subject(:document) do
      dor_harvester.document_builder.to_solr.first
    end

    it 'has a doc id' do
      expect(document[:id]).to eq druid
    end

    it 'has the gdor data' do
      expect(document).to include :collection, :modsxml, :url_fulltext
    end

    it 'has spotlight data' do
      expect(document).to include :spotlight_resource_id_ssim
    end

    it 'has exhibit-specific indexing' do
      expect(document).to include 'full_image_url_ssm'
    end
  end
end
