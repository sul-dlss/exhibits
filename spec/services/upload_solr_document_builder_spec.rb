require 'rails_helper'

describe UploadSolrDocumentBuilder do
  subject(:builder) { described_class.new resource }
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:featured_image) { instance_double(Spotlight::FeaturedImage) }
  let(:upload_id) { 123 }
  let(:riiif_image) { instance_double(Riiif::Image, info: { width: 5, height: 5 }) }

  let(:resource) { Spotlight::Resources::Upload.create! exhibit: exhibit, upload_id: upload_id }

  before do
    allow(Riiif::Image).to receive(:new).with(upload_id).and_return(riiif_image)
  end

  describe '#to_solr' do
    it 'adds a square thumbnail field' do
      expect(builder.to_solr).to include thumbnail_square_url_ssm: "/images/#{upload_id}/square/100,100/0/default.jpg"
    end
  end
end
