set :deploy_host, ENV['CAPISTRANO_PRODUCTION_DEPLOY_HOST'] || ask('deploy_host prefix (leave off stanford.edu)', '')
set :user, ENV['CAPISTRANO_PRODUCTION_USER'] || ask(:user, '')
set :bundle_without, %w(deployment development test).join(' ')

%w(a b).each do |suffix|
  server "#{fetch(:deploy_host)}-#{suffix}.stanford.edu",
         user: fetch(:user),
         roles: %w(web db app)
end

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, 'production'

set :delayed_job_workers, 8
