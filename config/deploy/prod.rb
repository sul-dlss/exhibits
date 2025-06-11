server 'exhibits-prod-a.stanford.edu', user: 'exhibits', roles: %w(web db app)
server 'exhibits-prod-b.stanford.edu', user: 'exhibits', roles: %w(web app)
server 'exhibits-worker-prod-a.stanford.edu', user: 'exhibits', roles: %w(app background)
server 'exhibits-worker-prod-b.stanford.edu', user: 'exhibits', roles: %w(app background)
server 'exhibits-bots.stanford.edu', user: 'exhibits', roles: %w(web db app)

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, 'production'

set :sidekiq_roles, :background
