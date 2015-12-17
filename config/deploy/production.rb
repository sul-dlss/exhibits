set :deploy_host, ENV['CAPISTRANO_PRODUCTION_DEPLOY_HOST'] || ask(:deploy_host, '')
set :user, ENV['CAPISTRANO_PRODUCTION_USER'] || ask(:user, '')

server "#{fetch(:deploy_host)}", user: fetch(:user), roles: %w(web db app)

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, 'production'

set :delayed_job_workers, 8