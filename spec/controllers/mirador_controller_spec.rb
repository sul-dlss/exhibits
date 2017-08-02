require 'rails_helper'

RSpec.describe MiradorController, type: :controller do
  describe '#index' do
    before { get :index, params: { manifest_url: 'holla' } }
    it { expect(response).to be_success }
    it 'sets @manifest_url' do
      expect(assigns(:manifest_url)).to eq 'holla'
    end
  end
end
