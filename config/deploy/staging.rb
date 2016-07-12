server 'exhibits-stage-a.stanford.edu', user: 'exhibits', roles: %w(web db app)
server 'exhibits-stage-b.stanford.edu', user: 'exhibits', roles: %w(web app)
server 'exhibits-worker-stage-a.stanford.edu', user: 'exhibits', roles: %w(app background)

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, 'production'

set :delayed_job_workers, 4
set :delayed_job_roles, [:background]
set :delayed_job_monitor, true
