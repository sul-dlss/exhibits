require 'rails_helper'

describe 'Bibliography Service Configuration', type: :request do
  include ActiveJob::TestHelper
  let(:exhibit) { create(:exhibit) }
  let(:user) { nil }
  let(:bibliography_service) { BibliographyService.create(exhibit_id: exhibit.id) }

  before do
    sign_in user
  end

  describe '#edit' do
    context 'an anonymous user' do
      it 'redirects to the login page' do
        get "/#{exhibit.slug}/services/edit"

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'an exhibit curator' do
      let(:user) { create(:curator) }

      it 'redirects to the home page with an alert indicating they do not have access' do
        get "/#{exhibit.slug}/services/edit"

        expect(flash[:alert]).to eq 'You are not authorized to access this page.'
        expect(response).to redirect_to root_url
      end
    end

    context 'an exhibit admin' do
      let(:user) { create(:exhibit_admin, exhibit: exhibit) }

      it 'is allowed' do
        get "/#{exhibit.slug}/services/edit"

        expect(response).to be_success
      end

      it 'sets an unpersisted BibliographyService object' do
        get "/#{exhibit.slug}/services/edit"

        object = assigns(:bibliography_service)
        expect(object).not_to be_persisted
        expect(object).to be_a BibliographyService
      end
    end
  end

  describe '#update' do
    context 'an anonymous user' do
      it 'redirects to the login page' do
        patch "/#{exhibit.slug}/services", params: { id: bibliography_service }

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'an exhibit admin' do
      let(:user) { create(:exhibit_admin, exhibit: exhibit) }
      let(:update_params) { { header: 'New Header' } }

      before do
        patch "/#{exhibit.slug}/services", params: {
          id: bibliography_service.id,
          bibliography_service: update_params
        }
      end

      it 'updates the bibliography service and redirects to the edit form' do
        object = assigns(:bibliography_service)
        expect(object.header).to eq 'New Header'
        expect(response).to redirect_to "/#{exhibit.slug}/services/edit"
      end

      it 'sets a flash notice indicating that the settings have been updated' do
        expect(flash[:notice]).to eq 'The bibliography service settings have been updated.'
      end

      context 'when the api_id is updated' do
        let(:update_params) { { api_id: 'new_api_id' } }

        it 'invokes the SyncBibliograhyService job' do
          expect(enqueued_jobs.size).to eq(1)
          last_job = enqueued_jobs.last
          expect(last_job[:job]).to eq SyncBibliographyServiceJob
        end
      end

      context 'when the api_type is updated' do
        let(:update_params) { { api_type: 'new_api_type' } }

        it 'invokes the SyncBibliograhyService job' do
          expect(enqueued_jobs.size).to eq(1)
          last_job = enqueued_jobs.last
          expect(last_job[:job]).to eq SyncBibliographyServiceJob
        end
      end

      context 'when the api configuration is not changed updated' do
        it 'the SyncBibliograhyService job is not invoked' do
          expect(enqueued_jobs.size).to eq(0)
        end
      end
    end
  end

  describe '#create' do
    context 'an anonymous user' do
      it 'redirects to the login page' do
        patch "/#{exhibit.slug}/services", params: { id: bibliography_service }

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'an exhibit admin' do
      let(:user) { create(:exhibit_admin, exhibit: exhibit) }

      before do
        post "/#{exhibit.slug}/services", params: {
          id: bibliography_service.id,
          bibliography_service: { api_id: 'abc123' }
        }
      end

      it 'creates the bibliography service and redirects to the edit form' do
        object = assigns(:bibliography_service)
        expect(object.api_id).to eq 'abc123'
        expect(response).to redirect_to "/#{exhibit.slug}/services/edit"
      end

      it 'sets a flash notice that the synchronization has started' do
        expect(flash[:notice]).to eq 'Synchronization with Zotero has started.'
      end

      it 'invokes the SyncBibliograhyService job' do
        expect(enqueued_jobs.size).to eq(1)
        last_job = enqueued_jobs.last
        expect(last_job[:job]).to eq SyncBibliographyServiceJob
      end
    end
  end
end
