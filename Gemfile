# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 6.1.0'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Use Puma as the app server
gem 'puma', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 2.7.2'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'

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
  gem 'capistrano-shared_configs'
  gem 'dlss-capistrano'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'listen', '~> 3.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :development do
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
  gem 'mysql2'
  gem 'newrelic_rpm'
end

gem 'config'

gem 'bootstrap'
gem 'blacklight', '~> 7.15'
gem 'blacklight-gallery', '~> 3', '>= 3.0.3'
gem 'blacklight_heatmaps'
gem 'blacklight-spotlight', '~> 3.0'
gem 'twitter-typeahead-rails', '0.11.1.pre.corejavascript'
gem 'blacklight_advanced_search'
gem 'blacklight_range_limit', '~> 8.0'
gem 'devise'
gem 'devise-guests', '~> 0.3'
gem 'devise-remote-user'
gem 'devise_invitable'
gem 'file_validators'
gem 'nokogiri', '>= 1.7.1'
gem 'turnout'
gem 'ruby-oembed'
gem 'okcomputer'
gem 'friendly_id', '~> 5.4'
gem 'sitemap_generator'

source 'https://gems.contribsys.com/' do
  gem 'sidekiq-pro'
end

gem 'sidekiq'
gem 'sul_styles'
gem 'dotenv'
gem 'sir_trevor_rails'
gem 'riiif'
gem 'rsolr'
gem 'faraday', '~> 1.0'
gem 'oauth2', '~> 1.4'
gem 'purl_fetcher-client', '~> 0.4'
gem 'stanford-mods', '~> 2.2', '>= 2.2.1'
gem 'solrizer'
gem 'honeybadger'
gem 'slowpoke'
gem 'traject'
gem 'jsonpath'
gem 'bibtex-ruby'
gem 'citeproc-ruby'
gem 'csl-styles'
gem 'acts-as-taggable-on'
gem 'mods_display', '~> 1.0.0.alpha1'
gem 'slack-ruby-client'
gem 'blacklight-oembed', '~> 1.0'

# Pinned, due to some incompatibility with ostruct 0.5 + rake
gem 'ostruct', '< 0.5'
