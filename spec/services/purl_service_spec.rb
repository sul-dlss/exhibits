# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PurlService do
  subject(:purl_service) { described_class.new('dx969tv9730', format: :mods) }

  let(:faraday_response) { instance_double(Faraday::Response, success?: true, body: '<mods>...</mods>') }

  before do
    allow(Faraday).to receive(:get).and_return(faraday_response)
  end

  describe '#exists?' do
    it 'returns true if the response is successful' do
      expect(purl_service.exists?).to be true
    end

    it 'returns false if there is an error' do
      allow(faraday_response).to receive(:success?).and_raise(Faraday::Error)
      expect(purl_service.exists?).to be false
    end
  end

  describe '#response_body' do
    it 'makes the request and returns the response body' do
      expect(purl_service.response_body).to eq('<mods>...</mods>')
      expect(Faraday).to have_received(:get).with('https://purl.stanford.edu/dx969tv9730.mods')
    end
  end
end
