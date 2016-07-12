require 'rails_helper'

describe DelayedJobsController, type: :controller do
  describe '#authenticate_user!' do
    context 'with admin user' do
      let(:user) { FactoryGirl.create(:admin) }
      before { sign_in user }
      it 'renders the index view' do
        get :index
        expect(response).to be_success
      end
    end
    context 'with a non-admin user' do
      let(:user) { FactoryGirl.create(:curator) }
      before { sign_in user }
      it 'raises CanCan::AccessDenied' do
        expect { get :index }.to raise_error(CanCan::AccessDenied)
      end
    end
    context 'without a signed-in user' do
      it 'redirects to the new_user_session_path' do
        get :index
        expect(response).not_to be_success
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
  describe '#update' do
    let(:user) { FactoryGirl.create(:admin) }
    let(:worker) do
      instance_double('Delayed::Worker')
    end
    let(:job) do
      instance_double('Delayed::Job',
                      id: job_id,
                      name: 'mock',
                      max_run_time: '',
                      invoke_job: '',
                      destroy: '')
    end
    let(:job_id) { 123_456 }
    before do
      sign_in user
      controller.instance_variable_set(:@delayed_job, job)
      allow(Delayed::Worker).to receive(:new) { worker }
    end
    it 'runs the job' do
      allow(worker).to receive(:run)
      put :update, id: job_id
      expect(worker).to have_received(:run).with(job)
    end
  end
  describe '#destroy' do
    let(:user) { FactoryGirl.create(:admin) }
    let(:job) do
      instance_double('Delayed::Job',
                      id: job_id,
                      name: 'mock',
                      max_run_time: '',
                      invoke_job: '',
                      destroy: '')
    end
    let(:job_id) { 123_456 }
    before do
      sign_in user
      controller.instance_variable_set(:@delayed_job, job)
    end
    it 'destroys the job' do
      allow(job).to receive(:destroy)
      delete :destroy, id: job_id
      expect(job).to have_received(:destroy)
    end
  end
end
