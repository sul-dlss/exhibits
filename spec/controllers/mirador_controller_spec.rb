# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MiradorController, type: :controller do
  describe '#index' do
    before { get :index, params: { manifest: 'holla', canvas: 'back', exhibit_slug: 'now' } }

    it { expect(response).to be_success }
    it 'sets @manifest' do
      expect(assigns(:manifest)).to eq 'holla'
    end
    it 'sets @canvas' do
      expect(assigns(:canvas)).to eq 'back'
    end
    it 'sets @exhibit_slug' do
      expect(assigns(:exhibit_slug)).to eq 'now'
    end
  end
end
