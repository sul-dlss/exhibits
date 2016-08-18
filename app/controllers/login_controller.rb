##
# Authentication controller that is protected externally (by WebAuth)
# and simply bounces users back to their initial request.
class LoginController < ApplicationController
  before_action only: :login do
    current_user.accept_invitation! if current_user
  end

  def login
    if params[:referrer]
      redirect_to params[:referrer]
    else
      redirect_back fallback_location: root_url
    end
  end

  private

  # Backport from Rails 5
  def redirect_back(fallback_location:, **args)
    if defined?(super)
      super
    elsif request.headers['Referer']
      redirect_to request.headers['Referer'], **args
    else
      redirect_to fallback_location, **args
    end
  end
end
