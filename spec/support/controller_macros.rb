module ControllerMacros
  def login_admin
    before do
      user = create(:admin)
      @request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in user
    end
  end

  def login_curator
    before do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      user = create(:curator)
      sign_in user
    end
  end

  def login_user
    before do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      user = create(:user)
      sign_in user
    end
  end
end
