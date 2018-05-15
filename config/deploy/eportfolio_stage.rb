server 'eportfolio-stage-a.stanford.edu', user: 'eportfolio', roles: %w(web db app)
server 'eportfolio-stage-b.stanford.edu', user: 'eportfolio', roles: %w(web app)
server 'eportfolio-worker-stage-a.stanford.edu', user: 'eportfolio', roles: %w(app background)

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, 'production'

set :sidekiq_roles, :background
set :sidekiq_processes, 6 # prod has 10 but stage box has more limited memory

set :deploy_to, "/opt/app/eportfolio/eportfolio"
