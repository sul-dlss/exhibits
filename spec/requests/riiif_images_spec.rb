# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Riiif images' do
  let(:image) { instance_double(Riiif::Image) }
  let(:error) { Riiif::ConversionError.new('identify: Not a JPEG file: starts with 0x00 0x00') }

  before do
    allow(Riiif::Image).to receive(:new).with('12611-abc').and_return(image)
  end

  context 'when the image file cannot be read by ImageMagick' do
    before do
      allow(image).to receive(:info).and_raise(error)
      allow(image).to receive(:render).and_raise(error)
    end

    it 'responds with not found for info.json' do
      get '/images/12611-abc/info.json'

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body).to eq('error' => 'no info')
    end

    it 'responds with not found for the image' do
      get '/images/12611-abc/full/full/0/default.jpg'

      expect(response).to have_http_status(:not_found)
    end
  end
end
