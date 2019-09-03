# frozen_string_literal: true

require 'rails_helper'

describe UploadSolrDocumentBuilder do
  subject(:builder) { described_class.new resource }

  let(:exhibit) { create(:exhibit) }
  let(:upload_id) { 123 }
  let(:upload) { Spotlight::FeaturedImage.new(id: upload_id) }
  let(:riiif_image) do
    instance_double(Riiif::Image, info: instance_double('Dimensions', width: 5, height: 5))
  end

  let(:resource) { Spotlight::Resources::Upload.create! exhibit: exhibit, upload: upload }

  before do
    allow(Riiif::Image).to receive(:new).with(upload_id).and_return(riiif_image)
    allow(upload).to receive(:file_present?).and_return(true)
  end

  describe '#to_solr' do
    it 'adds a square thumbnail field' do
      expect(builder.to_solr).to include thumbnail_square_url_ssm: "/images/#{upload_id}/square/100,100/0/default.jpg"
    end
  end
end
