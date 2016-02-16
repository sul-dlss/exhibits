server 'exhibits-prod-a.stanford.edu', user: 'exhibits', roles: %w(web db app)
server 'exhibits-prod-b.stanford.edu', user: 'exhibits', roles: %w(web db app)

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, 'production'

set :delayed_job_workers, 8
