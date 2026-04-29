# frozen_string_literal: true

##
# A wrapper class around the Slack Web Client.
# All public methods are delegated through the class itself so things like
# ExhibitBot.message(text: 'My Message Content') will simply work anywhere.
class ExhibitBot
  class << self
    delegate :message, to: :new
  end

  def message(channels: default_channels, as_user: true, text:)
    channels.each do |channel|
      client.chat_postMessage(channel: channel, as_user: as_user, text: text)
    end
  end

  private

  def default_channels
    Settings.slack_notifications.default_channels
  end

  def client
    @client ||= if FeatureFlags.new.slack_notifications?
                  Slack::Web::Client.new(ca_file: nil, ca_path: nil)
                else
                  NullClient.new
                end
  end

  # rubocop: disable Naming/MethodName
  # NullObject pattern returned when we're not configured to send slack notifications
  class NullClient
    # noop
    def chat_postMessage(*args); end
  end
  # rubocop: enable Naming/MethodName
end
