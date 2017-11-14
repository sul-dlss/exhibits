# frozen_string_literal: true

##
# Authentication controller that is protected externally (by WebAuth)
# and simply bounces users back to their initial request.
class LoginController < ApplicationController
  before_action only: :login do
    current_user&.accept_invitation!
  end

  def login
    if params[:referrer]
      redirect_to params[:referrer]
    else
      redirect_back fallback_location: root_url
    end
  end
end
