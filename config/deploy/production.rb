server 'exhibits-prod-a.stanford.edu', user: 'exhibits', roles: %w(web db app)
server 'exhibits-prod-b.stanford.edu', user: 'exhibits', roles: %w(web app)
server 'exhibits-worker-prod-a.stanford.edu', user: 'exhibits', roles: %w(app background)

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, 'production'

set :sidekiq_role, :background
set :sidekiq_processes, 10
set :sidekiq_concurrency, 5