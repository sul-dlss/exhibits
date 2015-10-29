module ControllerMacros
  def login_admin
    before(:each) do
      user = FactoryGirl.create(:admin)
      @request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in user
    end
  end

  def login_curator
    before(:each) do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      user = FactoryGirl.create(:curator)
      sign_in user
    end
  end

  def login_user
    before(:each) do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      user = FactoryGirl.create(:user)
      sign_in user
    end
  end
end
