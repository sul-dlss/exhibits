# frozen_string_literal: true

# :nodoc:
class ApplicationController < ActionController::Base
  include BotChallengePage::Controller
  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include Spotlight::Controller

  before_action :set_paper_trail_whodunnit

  # Please be sure to impelement current_user and user_session. Blacklight depends on
  # these methods in order to perform user specific actions.

  layout 'spotlight/spotlight'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def feature_flags
    @feature_flags ||= FeatureFlags.for(current_exhibit)
  end
  helper_method :feature_flags

  private

  def after_sign_out_path_for(*)
    '/Shibboleth.sso/Logout'
  end
end
