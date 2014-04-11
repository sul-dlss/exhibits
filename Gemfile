source 'https://rubygems.org'
source 'http://sul-gems.stanford.edu'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.4'

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
  gem 'lyberteam-capistrano-devel', '3.0.0.pre1'
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

gem "blacklight"
gem "blacklight-gallery", github: "projectblacklight/blacklight-gallery"
gem "blacklight-maps", github: "sul-dlss/blacklight-maps"
gem 'openseadragon', github: "iiif/openseadragon-rails"
gem "blacklight-spotlight", github: "sul-dlss/spotlight"
gem "sir-trevor-rails", github: "sul-dlss/sir-trevor-rails"
gem "jettywrapper"
gem "devise"
gem "devise-guests", "~> 0.3"
