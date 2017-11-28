if Rails.env.test?
  require 'webmock/rspec'
  WebMock.allow_net_connect!
  WebMock.stub_request(:get, /embed\.json/) # For async page loads for oEmbed
end
