# frozen_string_literal: true

require 'rails_helper'

describe Spotlight::CatalogController do
  routes { Spotlight::Engine.routes }

  let(:exhibit) { create(:exhibit) }
  let(:user) { create(:exhibit_admin, exhibit: exhibit) }

  before do
    sign_in user
  end

  describe '#manifest' do
    it 'sets appropriate CORS headers' do
      get :manifest, params: { id: 1, exhibit_id: exhibit.id, locale: 'en' }

      expect(response.headers.to_h).to include 'Access-Control-Allow-Origin' => '*'
    end
  end
end
