require 'rails_helper'

RSpec.describe 'gdor indexing integration test', type: :feature do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:druid) { 'xf680rd3068' }

  before do
    stub_const('Harvestdor::PURL_DEFAULT', File.expand_path(File.join('..', '..', 'fixtures'), __FILE__))
  end

  subject do
    r = DorHarvester.new(druid_list: druid, exhibit: exhibit)
    allow(r).to receive(:to_global_id).and_return('x')
    r.document_builder.to_solr.first
  end

  it 'has a doc id' do
    expect(subject[:id]).to eq druid
  end

  it 'has the gdor data' do
    expect(subject).to include :collection, :modsxml, :url_fulltext
  end

  it 'has spotlight data' do
    expect(subject).to include :spotlight_resource_id_ssim
  end

  it 'has exhibit-specific indexing' do
    expect(subject).to include 'full_image_url_ssm'
  end

  it 'can write the document to solr' do
    r = DorHarvester.new(druid_list: druid)
    allow(r).to receive(:to_global_id).and_return('x')
    allow(r).to receive(:exhibit).and_return(exhibit)
    r.reindex
  end
end
