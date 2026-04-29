# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SendPublishStateChangeNotificationJob do
  let(:job) { described_class.perform_now(exhibit: exhibit, published: published) }
  let(:exhibit) { FactoryBot.create(:exhibit) }

  context 'when publishing' do
    let(:published) { true }

    it 'sends a message indicating the exhibit has been published' do
      allow(ExhibitBot).to receive(:message)

      job

      expect(ExhibitBot).to have_received(:message).with(
        a_hash_including(
          text: a_string_including("Spotlight exhibit published: #{exhibit.title}")
        )
      )
    end
  end

  context 'when un-publishing' do
    let(:published) { false }

    it 'indicates an item is un-published' do
      allow(ExhibitBot).to receive(:message)

      job

      expect(ExhibitBot).to have_received(:message).with(
        a_hash_including(
          text: a_string_including("Spotlight exhibit un-published: #{exhibit.title}")
        )
      )
    end
  end

  context 'when multiple default channels are configured' do
    let(:published) { true }
    let(:stub_client) { instance_spy(Slack::Web::Client) }
    let(:bot) { ExhibitBot.new }

    before do
      allow(ExhibitBot).to receive(:new).and_return(bot)
      allow(bot).to receive_messages(client: stub_client, default_channels: ['#channel-one', '#channel-two'])
    end

    it 'sends the same message text to each channel' do
      job

      expect(stub_client).to have_received(:chat_postMessage)
        .with(hash_including(channel: '#channel-one',
                             text: a_string_including("Spotlight exhibit published: #{exhibit.title}")))
      expect(stub_client).to have_received(:chat_postMessage)
        .with(hash_including(channel: '#channel-two',
                             text: a_string_including("Spotlight exhibit published: #{exhibit.title}")))
    end
  end
end
