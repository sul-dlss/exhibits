require 'rails_helper'

describe LoginController do
  let(:user) { create(:curator) }
  before do
    allow_any_instance_of(ApplicationController).to receive_messages(current_user: user)
    request.env['HTTP_REFERER'] = 'http://example.com'
  end

  it 'accepts the user invitation on login and redirects to the referrer' do
    expect(user).to receive(:accept_invitation!)
    get :login, referrer: '/home'
    expect(response).to redirect_to '/home'
  end
end
