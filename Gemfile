# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.2.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 2.7.2'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'

# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

group :deployment do
  gem 'capistrano', '~> 3.0'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-passenger'
  gem 'capistrano-sidekiq'
  gem 'capistrano-shared_configs'
  gem 'dlss-capistrano'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'letter_opener'
end

group :development, :test do
  gem 'solr_wrapper'
  # Use sqlite3 as the database for Active Record
  gem 'sqlite3'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri

  gem 'database_cleaner'

  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
end

group :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'rails-controller-testing'
  gem 'capybara'
  gem 'webdrivers'
  gem 'selenium-webdriver', '!= 3.13.0'
  gem 'simplecov', require: false
  gem 'webmock'
end

group :production do
  # mysql 0.5.3 is not compatible with the version of ruby we are using
  gem 'mysql2', '< 0.5.3'
  gem 'newrelic_rpm'
end

gem 'config'

gem 'bootstrap'
gem 'blacklight', '~> 7.0'
gem 'blacklight-gallery', '~> 1.2'
gem 'blacklight_heatmaps'
gem 'blacklight-spotlight', '3.0.0.alpha.4'
gem 'twitter-typeahead-rails', '0.11.1.pre.corejavascript'
gem 'blacklight_advanced_search', github: 'projectblacklight/blacklight_advanced_search'
gem 'blacklight_range_limit', '~> 7.0'
gem 'devise'
gem 'devise-guests', '~> 0.3'
gem 'devise-remote-user'
gem 'devise_invitable'
gem 'file_validators'
gem 'nokogiri', '>= 1.7.1'
gem 'turnout'
gem 'ruby-oembed'
gem 'okcomputer'
gem 'friendly_id', '~> 5.2.0'
gem 'sitemap_generator'

source 'https://gems.contribsys.com/' do
  gem 'sidekiq-pro', '~> 5.0'
end

gem 'sidekiq', '~> 5.0'
gem 'sul_styles'
gem 'dotenv'
gem 'sir_trevor_rails'
gem 'riiif'
gem 'rsolr'
gem 'faraday'
# We have to pin net-http-persistent to before the 3.0.0 release due to an issue w/ faraday.
# Faraday 0.13.0 resolves this issue, but we're curren't unable to upgrade to that due to
# oauth2 (1.4.0) requiring Faraday < 0.13.0
gem 'oauth2', '~> 1.4'
gem 'net-http-persistent', '< 3'
gem 'harvestdor-indexer', '~> 2.4'
gem 'stanford-mods', '~> 2.2', '>= 2.2.1'
gem 'solrizer'
gem 'honeybadger'
gem 'slowpoke'
gem 'mirador_rails'
gem 'traject'
gem 'jsonpath'
gem 'bibtex-ruby'
gem 'citeproc-ruby'
gem 'csl-styles'
gem 'acts-as-taggable-on'
gem 'mods_display'
gem 'slack-ruby-client'
gem 'blacklight-oembed', '~> 1.0'
