require 'rails_helper'

describe 'spotlight/shared/_configuration_sidebar', type: :view do
  subject { rendered }

  describe 'Services' do
    let(:current_exhibit) { FactoryGirl.create(:exhibit) }

    before do
      allow(view).to receive(:can?).and_return true
      expect(view).to receive_messages(current_exhibit: current_exhibit)
    end
    context 'when enabled' do
      it do
        render
        is_expected.to have_link 'Services'
      end
    end
    context 'when disabled' do
      around do |example|
        Settings.sync_bibliography_service.enabled = false
        example.run
        # Set it back to the current default
        Settings.sync_bibliography_service.enabled = true
      end
      it do
        render
        is_expected.not_to have_link 'Services'
      end
    end
  end
end
