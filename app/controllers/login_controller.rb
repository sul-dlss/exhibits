##
# Authentication controller that is protected externally (by WebAuth)
# and simply bounces users back to their initial request.
class LoginController < ApplicationController
  def login
    redirect_to params[:referrer] || :back
  end
end
