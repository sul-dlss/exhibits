##
# Authentication controller that is protected externally (by WebAuth)
# and simply bounces users back to their initial request.
class LoginController < ApplicationController
  before_action only: :login do
    current_user.accept_invitation! if current_user
  end

  def login
    redirect_to params[:referrer] || :back
  end
end
