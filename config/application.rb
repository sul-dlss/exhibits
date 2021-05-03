require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Exhibits
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.autoload_paths << Rails.root.join('lib')

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
  end
end
