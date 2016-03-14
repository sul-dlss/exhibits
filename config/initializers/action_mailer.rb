if defined?(Settings) && Settings.action_mailer
  if Settings.action_mailer.default_url_options
    Exhibits::Application.config.action_mailer.default_url_options = Settings.action_mailer.default_url_options.try(:to_h) || {}
  end

  if Settings.action_mailer.default_options
    Exhibits::Application.config.action_mailer.default_options = Settings.action_mailer.default_options.try(:to_h) || {}
  end
end
