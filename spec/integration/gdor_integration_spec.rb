require 'spec_helper'

describe "indexing integration test", :vcr do
  subject do
    Spotlight::Resources::Purl.new(url: "http://purl.stanford.edu/xf680rd3068").to_solr
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