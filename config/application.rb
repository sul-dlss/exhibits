require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Exhibits
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Inject our ExhibitExtension concern to add behavior
    # (like relationships) to the Spotlight::Exhibit class
    config.to_prepare do
      Spotlight::Exhibit.send(:include, ExhibitExtension)
    end

    config.druid_regex = /([a-z]{2}[0-9]{3}[a-z]{2}[0-9]{4})/

    # Setting this to false so that views we render under the context of a
    # Spotlight contorller are not required to be in the spotlight directory
    config.action_view.prefix_partial_path_with_controller_namespace = false
  end
end
