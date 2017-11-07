source 'https://rubygems.org'

gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 2.7.2'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2', '>= 4.2.1'
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
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :development, :test do
  gem 'solr_wrapper'
  # Use sqlite3 as the database for Active Record
  gem 'sqlite3'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri

  gem 'database_cleaner'

  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
end

group :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'rails-controller-testing'
  gem 'capybara'
  gem 'chromedriver-helper'
  gem 'selenium-webdriver'
  gem 'coveralls', require: false
end

group :production do
  gem 'mysql2', '~> 0.4.4'
  gem 'newrelic_rpm'
end

gem 'config'

gem 'bootstrap-sass', '~> 3.3.5'

gem 'blacklight', '~> 6.3'
gem 'blacklight-gallery', '~> 0.3'
gem 'blacklight_heatmaps'
gem 'blacklight-spotlight', git: 'https://github.com/projectblacklight/spotlight', branch: 'master'
gem 'blacklight_advanced_search'
gem 'devise'
gem 'devise-guests', '~> 0.3'
gem 'devise-remote-user'
gem 'devise_invitable'
gem 'nokogiri', '>= 1.7.1'
gem 'rack-dev-mark'
gem 'turnout'
gem 'whenever'
gem 'ruby-oembed'
gem 'okcomputer'
gem 'friendly_id', '~> 5.2.0'
gem 'sitemap_generator'
gem 'sidekiq'
gem 'sul_styles'
gem 'dotenv'
gem 'sir_trevor_rails'
gem 'riiif'
gem 'rsolr'
gem 'faraday'
gem 'net-http-persistent', '< 3' # 3.x is incompatible with Faraday 0.9
gem 'harvestdor-indexer', '~> 2.4'
gem 'stanford-mods', '~> 2.2', '>= 2.2.1'
gem 'solrizer'
gem 'honeybadger', '~> 2.0'
gem 'slowpoke'
gem 'mirador_rails'
gem 'traject'
gem 'jsonpath'
gem 'bibtex-ruby'
gem 'citeproc-ruby'
gem 'csl-styles'
gem 'acts-as-taggable-on'
