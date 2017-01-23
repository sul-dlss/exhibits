# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
require File.expand_path('../config/application', __FILE__)

task default: :ci

Exhibits::Application.load_tasks

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new(:rubocop) do |task|
    task.fail_on_error = true
  end

  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
  # this rescue block is here for deployment to production, where
  # certain dependencies are not expected, and that is OK
  STDERR.puts 'WARNING: RSpec and/or Rubocop was not found and could not be required.'
end

desc 'Run tests in generated test Rails app with generated Solr instance running'
task ci: [:rubocop, :environment] do
  require 'solr_wrapper'
  ENV['environment'] = 'test'
  SolrWrapper.wrap(port: '8983') do |solr|
    solr.with_collection(name: 'blacklight-core', dir: Rails.root.join('solr', 'config')) do
      # run the tests
      Rake::Task['spotlight:seed'].invoke
      Rake::Task['spec'].invoke
    end
  end
end

desc 'Run solr and launch the development Rails server'
task server: [:environment] do
  require 'solr_wrapper'
  SolrWrapper.wrap(port: '8983') do |solr|
    solr.with_collection(name: 'blacklight-core', dir: Rails.root.join('solr', 'config')) do
      system 'bundle exec rake spotlight:seed'

      unless File.exist? 'tmp/.initialized'
        system 'bundle exec rake spotlight:initialize'
        File.open('tmp/.initialized', 'w') {}
      end
      system 'bundle exec rails s'
    end
  end
end

namespace :spotlight do
  task seed: [:environment] do
    docs = JSON.parse(File.read(Rails.root.join('spec', 'fixtures', 'sample_solr_docs.json')))
    conn = Blacklight.default_index.connection
    conn.add docs
    conn.commit
  end
end
