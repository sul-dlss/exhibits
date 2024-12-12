server 'exhibits-stage-a.stanford.edu', user: 'exhibits', roles: %w(web db app)
server 'exhibits-stage-b.stanford.edu', user: 'exhibits', roles: %w(web app)
server 'exhibits-worker-stage-a.stanford.edu', user: 'exhibits', roles: %w(background)
server 'exhibits-worker-stage-b.stanford.edu', user: 'exhibits', roles: %w(background)

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, 'production'

set :sidekiq_roles, :background
