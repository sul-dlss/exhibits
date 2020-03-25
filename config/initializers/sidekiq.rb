Sidekiq::Client.reliable_push! unless Rails.env.test?

Sidekiq.configure_server do |config|
  config.super_fetch!
  config.reliable_scheduler!
  config.logger.level = Object.const_get(Settings.sidekiq.logger_level)
end
