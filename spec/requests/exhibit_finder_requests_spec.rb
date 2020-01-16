# frozen_string_literal: true

require 'rails_helper'

describe 'Exhibit Finder API', type: :request do
  let(:exhibit) { create(:exhibit) }

  describe '#show' do
    before do
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(ExhibitFinder).to receive_messages(
        documents: [
          SolrDocument.new(
            id: 'abc123',
            spotlight_exhibit_slugs_ssim: [exhibit.slug],
            "exhibit_#{exhibit.slug}_public_bsi": [true]
          )
        ]
      )
      # rubocop:enable RSpec/AnyInstance
    end

    it 'returns JSON exhibit representations' do
      get '/exhibit_finder/abc123'

      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq 1
      expect(json_response.first['slug']).to eq exhibit.slug
    end

    it 'has the appropriate CORS headers to be available to JS clients' do
      get '/exhibit_finder/abc123'

      expect(response.headers['Access-Control-Allow-Origin']).to eq '*'
    end
  end
end
