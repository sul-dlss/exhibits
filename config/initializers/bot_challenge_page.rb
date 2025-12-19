# frozen_string_literal: true

# Add bot challenge to Spotlight controllers
Rails.application.config.to_prepare do
  Spotlight::AboutPagesController.bot_challenge only: :show
  Spotlight::BrowseController.bot_challenge only: %i(index show)
  Spotlight::FeaturePagesController.bot_challenge only: :show
end

SAFELIST = [
  '171.64.0.0/14',
  '10.0.0.0/8',
  '172.16.0.0/12',
  '192.168.0.0/16',
  '35.203.130.101', # Lane Google Cloud IP
  '35.203.131.135', # Lane Google Cloud IP
  '35.192.213.120', # Lane Google Cloud IP
  '104.198.197.19', # Lane Google Cloud IP
  '13.58.165.213',  # Siteimprove US Crawlers
  '18.116.191.222',
  '18.116.197.208',
  '18.189.206.159',
  '18.190.68.80',
  '18.216.137.252',
  '18.223.191.8',
  '3.13.121.241',
  '3.133.38.181',
  '3.135.49.180',
  '18.219.35.44',
  '3.136.111.218',
  '3.138.54.100',
  '3.129.126.175',
  '3.124.152.112'
].freeze

BotChallengePage.configure do |config|
  # Can globally disable in configuration if desired
  config.enabled = ENV.fetch('TURNSTILE_ENABLED', 'false').downcase == 'true'

  # Get from CloudFlare Turnstile: https://www.cloudflare.com/application-services/products/turnstile/
  # Some testing keys are also available: https://developers.cloudflare.com/turnstile/troubleshooting/testing/
  #
  # Always pass testing sitekey: "1x00000000000000000000AA"
  config.cf_turnstile_sitekey = ENV.fetch('TURNSTILE_SITE_KEY', nil)

  # Always pass testing secret_key: "1x0000000000000000000000000000000AA"
  config.cf_turnstile_secret_key = ENV.fetch('TURNSTILE_SECRET_KEY', nil)

  # For rate-limiting, we need a rails cache store that keeps state, by default
  # will use `config.action_controller.cache_store` or Rails.cache, but if you'd
  # like to use a separate store database, eg. :
  # config.store = ActiveSupport::Cache::RedisCacheStore.new(url: "...")

  # Filter to omit requests from bot challenge control, executed in controller instance context
  #
  config.skip_when = ->(config) {
    (is_a?(CatalogController) &&
     params[:action].in?(%w[facet index]) &&
     request.format.json? && 
     request.headers['sec-fetch-dest'] == 'empty') ||
     request.user_agent&.match?('HathiTrust-CRMS') || # for HathiTrust access to copyright exhibit
     request.user_agent&.match?('Siteimprove') || # for Siteimprove crawling
     SAFELIST.map { |cidr| IPAddr.new(cidr) }.any? { |range| request.remote_ip.in?(range) }
  }

  # Hook after a bot challenge is presented, for logging or other
  # config.after_blocked = ->(bot_challenge_controller) {
  # }

  # How long will a challenge success exempt a session from further challenges?
  # config.session_passed_good_for = 36.hours

  # Functions like to Rails rate_limit `by` parameter, as a configured default.
  # A discriminator or identifier in which a client's requests will be bucketted
  # by rate limit. Normally this gem buckets by IP address subnets. Switching
  # to individual IPs would be much more generous:
  # config.default_limit_by = ->(config) {
  #   request.remote_ip
  #  }

  # When a "pass" cookie is saved, a fingerprint value is stored with it,
  # and subsequent uses of the pass need to have a request that matches
  # fingerprint. By default we insist on IP subnet match, and same user-agent
  # and other headers. But can be customized.
  # config.session_valid_fingerprint = ->(request) {
  #    # whatever
  # }
end
