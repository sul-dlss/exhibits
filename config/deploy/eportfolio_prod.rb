server 'eportfolio-prod-a.stanford.edu', user: 'eportfolio', roles: %w(web db app)
server 'eportfolio-prod-b.stanford.edu', user: 'eportfolio', roles: %w(web app)
server 'eportfolio-worker-prod-a.stanford.edu', user: 'eportfolio', roles: %w(app background)

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, 'production'

set :sidekiq_roles, :background
set :sidekiq_processes, 10

set :deploy_to, "/opt/app/eportfolio/eportfolio"
