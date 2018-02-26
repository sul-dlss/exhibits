server 'exhibits-stage-a.stanford.edu', user: 'exhibits', roles: %w(web db app)
server 'exhibits-stage-b.stanford.edu', user: 'exhibits', roles: %w(web app)
server 'exhibits-worker-stage-a.stanford.edu', user: 'exhibits', roles: %w(app background)

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, 'production'

set :sidekiq_roles, :background
set :sidekiq_processes, 6 # prod has 10 but stage box has more limited memory
