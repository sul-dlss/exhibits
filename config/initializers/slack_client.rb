Slack.configure do |config|
  config.token = Settings.slack_notifications.api_token
end if FeatureFlags.new.slack_notifications?
