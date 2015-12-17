if defined? Settings and Settings.action_mailer and Settings.action_mailer.default_url_options
  Exhibits::Application.config.action_mailer.default_url_options = Settings.action_mailer.default_url_options.try(:to_h) || {}
end
