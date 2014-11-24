source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.8'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.2'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]
group :deployment do
  gem 'capistrano', '~> 3.0'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'lyberteam-capistrano-devel', '3.1.0'
end

group :development, :test do
  gem 'jettywrapper'
  # Use sqlite3 as the database for Active Record
  gem 'sqlite3'
end

group :production do
  gem 'mysql2'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', platforms: :ruby
end

gem 'squash_ruby', require: 'squash/ruby'
gem 'squash_rails', require: 'squash/rails'

gem "rails_config"

gem "blacklight", git: "https://github.com/projectblacklight/blacklight"
gem "blacklight-gallery", git: "https://github.com/projectblacklight/blacklight-gallery"
gem "blacklight-maps", git: "https://github.com/sul-dlss/blacklight-maps"
gem "blacklight-spotlight", git: "https://github.com/sul-dlss/spotlight"
gem "sir-trevor-rails", git: "https://github.com/sul-dlss/sir-trevor-rails"
gem "devise"
gem "devise-guests", "~> 0.3"
gem 'devise-remote-user'
gem "rack-dev-mark"
gem "turnout"
gem "whenever"
gem "ruby-oembed"

gem "friendly_id"
gem "social-share-button"