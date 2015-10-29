class LoginController < ApplicationController
  def login
    redirect_to params[:referrer] || :back
  end
end
