set :deploy_host, ENV['CAPISTRANO_STAGE_USER'] || ask(:deploy_host, '')
set :user, ENV['CAPISTRANO_STAGE_USER'] || ask(:user, '')

server "#{fetch(:deploy_host)}", user: fetch(:user), roles: %w(web db app)

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, 'production'
