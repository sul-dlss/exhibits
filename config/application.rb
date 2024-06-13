require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require_relative '../lib/feature_flags'

module Exhibits
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.autoload_paths << Rails.root.join('lib')

    # List of classes deemed safe to load by YAML.
    # Rails 7.0.3.1 YAML safe-loading method does not allow all classes
    # to be deserialized by default:
    # https://discuss.rubyonrails.org/t/cve-2022-32224-possible-rce-escalation-bug-with-serialized-columns-in-active-record/81017
    config.active_record.yaml_column_permitted_classes = [
      ActiveSupport::HashWithIndifferentAccess,
      ActiveSupport::TimeWithZone,
      ActiveSupport::TimeZone,
      Date,
      Symbol,
      Time
    ]

    config.time_zone = 'Pacific Time (US & Canada)'

    ##
    # Inject our ExhibitExtension concern to add behavior
    # (like relationships) to the Spotlight::Exhibit class
    # Also enable CarrierWave::MiniMagick for resizing
    config.to_prepare do
      Spotlight::Exhibit.send(:include, ExhibitExtension)
      Spotlight::AttachmentUploader.send(:include, CarrierWave::MiniMagick)
      Spotlight::AttachmentUploader.send(:process, resize_to_limit: [2000, 2000])
    end

    config.druid_regex = /([a-z]{2}[0-9]{3}[a-z]{2}[0-9]{4})/

    Recaptcha.configure do |config|
      config.site_key = ENV.fetch('RECAPTCHA_SITE_KEY', '6Lc6BAAAAAAAAChqRbQZcn_yyyyyyyyyyyyyyyyy')
      config.secret_key = ENV.fetch('RECAPTCHA_SECRET_KEY', '6Lc6BAAAAAAAAKN3DRm6VA_xxxxxxxxxxxxxxxxx')
    end
  end
end
