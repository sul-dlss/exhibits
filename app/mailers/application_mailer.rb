# frozen_string_literal: true

##
# A base mailer for our application
class ApplicationMailer < ActionMailer::Base
  default from: Settings.action_mailer.default_options.from
  layout 'mailer'
end
