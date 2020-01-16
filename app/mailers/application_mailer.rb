# frozen_string_literal: true

##
# A base mailer for our application
class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'
end
