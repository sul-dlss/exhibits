source 'https://rubygems.org'

gem 'rails', '4.2.7.1'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 2.7.2'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2.1'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

group :deployment do
  gem 'capistrano', '~> 3.0'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-passenger'
  gem 'capistrano-sidekiq'
  gem 'dlss-capistrano'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console'
end

group :development, :test do
  gem 'solr_wrapper'
  # Use sqlite3 as the database for Active Record
  gem 'sqlite3'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  gem 'database_cleaner'

  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
end

group :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'coveralls', require: false
end

group :production do
  gem 'mysql2', '~> 0.4.4'
end

gem 'config'

gem 'bootstrap-sass', '~> 3.3.5'

gem 'blacklight', '~> 6.3'
gem 'blacklight-gallery', '~> 0.3'
gem 'blacklight_heatmaps'
gem 'blacklight-spotlight', '~> 0.27'
gem 'devise'
gem 'devise-guests', '~> 0.3'
gem 'devise-remote-user'
gem 'devise_invitable'
gem 'rack-dev-mark'
gem 'turnout'
gem 'whenever'
gem 'ruby-oembed'
gem 'okcomputer'
gem 'friendly_id'
gem 'sitemap_generator'
gem 'sidekiq'
gem 'sidekiq-statistic'
gem 'sul_styles'
gem 'dotenv'
gem 'sir_trevor_rails'
gem 'spotlight-resources-iiif'
gem 'riiif', '~> 0.4.0'
gem 'rsolr'
gem 'gdor-indexer', '~> 0.6'
gem 'faraday'
gem 'harvestdor-indexer', '~> 2.4'
gem 'stanford-mods', '~> 2.2', '>= 2.2.1'
gem 'solrizer'
gem 'honeybadger', '~> 2.0'
