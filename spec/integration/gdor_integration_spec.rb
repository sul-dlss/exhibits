require 'spec_helper'

describe "indexing integration test", :vcr do
  let :exhibit do
    double(solr_data: { }, blacklight_config: Blacklight::Configuration.new)
  end

  subject do
    r = Spotlight::Resources::Purl.new(url: "http://purl.stanford.edu/xf680rd3068")
    allow(r).to receive(:to_global_id).and_return('x')
    allow(r).to receive(:exhibit).and_return(exhibit)
    r.to_solr.first
  end

  it "should have a doc id" do
    expect(subject[:id]).to eq "xf680rd3068"
  end

  it "should have the gdor data" do
    expect(subject).to include :collection, :modsxml, :url_fulltext
  end

  it "should have spotlight data" do
    expect(subject).to include :spotlight_resource_id_ssim
  end

  it "should have exhibit-specific indexing" do
    expect(subject).to include "full_image_url_ssm"
  end
end