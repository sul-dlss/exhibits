RSpec.describe Spotlight::Resources::DorHarvesterController, type: :controller do
  routes { Spotlight::Dor::Resources::Engine.routes }
  let(:resource) { double }
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:user) { FactoryGirl.create(:exhibit_admin, exhibit: exhibit) }
  let(:attributes) { { druid_list: '' } }

  before do
    sign_in user
    allow(Spotlight::Resources::DorHarvester).to receive(:instance).and_return(resource)
    expect(resource).to receive(:update).with(attributes)
    allow(resource).to receive(:save_and_index).and_return(save_status)
  end

  describe '#create' do
    context 'when save is successful' do
      let(:save_status) { true }

      it 'goes to the exhibit' do
        post :create, exhibit_id: exhibit.id, resources_dor_harvester: attributes

        expect(response).to redirect_to Spotlight::Engine.routes.url_helpers.admin_exhibit_catalog_path(exhibit)
      end
    end

    context 'when save is unsuccessful' do
      let(:save_status) { false }

      it 'goes to the exhibit' do
        post :create, exhibit_id: exhibit.id, resources_dor_harvester: attributes

        expect(response).to redirect_to Spotlight::Engine.routes.url_helpers.new_exhibit_resource_path(exhibit)
      end
    end
  end

  describe '#update' do
    context 'when save is successful' do
      let(:save_status) { true }

      it 'goes to the exhibit' do
        patch :update, exhibit_id: exhibit.id, resources_dor_harvester: attributes

        expect(response).to redirect_to Spotlight::Engine.routes.url_helpers.admin_exhibit_catalog_path(exhibit)
      end
    end

    context 'when save is unsuccessful' do
      let(:save_status) { false }

      it 'goes to the exhibit' do
        patch :update, exhibit_id: exhibit.id, resources_dor_harvester: attributes

        expect(response).to redirect_to Spotlight::Engine.routes.url_helpers.new_exhibit_resource_path(exhibit)
      end
    end
  end
end
