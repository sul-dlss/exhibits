set :application, 'spotlight'
set :repo_url, 'https://github.com/sul-dlss/exhibits.git'

# Default branch is :master
ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call unless ENV['DEPLOY']

# Default deploy_to directory is /var/www/my_app
set :deploy_to, "/opt/app/exhibits/exhibits"

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :info

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w(public/robots.txt config/secrets.yml config/database.yml config/blacklight.yml config/honeybadger.yml config/newrelic.yml)

# Default value for linked_dirs is []
set :linked_dirs, %w(log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/uploads config/settings)

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# update shared_configs before restarting app
before 'deploy:restart', 'shared_configs:update'

namespace :deploy do
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'tmp:cache:clear'
        end
      end
    end
  end
  after :restart, :restart_sidekiq do
    on roles(:background) do
      sudo :systemctl, "restart", "sidekiq-*", raise_on_non_zero_exit: false
    end
  end
end

# honeybadger_env otherwise defaults to rails_env
set :honeybadger_env, "#{fetch(:stage)}"
