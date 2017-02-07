namespace :spotlight do
  desc 'Update to the latest blacklight + spotlight dependencies'
  task upgrade: :environment do
    Bundler.with_clean_env do
      system 'bundle update blacklight blacklight-spotlight spotlight-dor-resources'
      system 'bundle exec rake blacklight:install:migrations'
      system 'bundle exec rake spotlight:install:migrations'
      system 'bundle exec rake db:migrate'
    end
  end
end
