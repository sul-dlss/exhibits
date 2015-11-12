# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

task default: [:ci, :rubocop]

SulExhibitsTemplate::Application.load_tasks

ZIP_URL = 'https://github.com/projectblacklight/blacklight-jetty/archive/v4.10.4.zip'

begin

  require 'rubocop/rake_task'
  RuboCop::RakeTask.new(:rubocop)

  require 'jettywrapper'
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)

  desc 'Run tests in generated test Rails app with generated Solr instance running'
  task ci: ['jetty:clean', 'spotlight:configure_jetty'] do
    ENV['environment'] = 'test'
    jetty_params = Jettywrapper.load_config
    jetty_params[:startup_wait] = 60

    Jettywrapper.wrap(jetty_params) do
      # run the tests
      Rake::Task['spec'].invoke
    end
  end
rescue LoadError
  # this rescue block is here for deployment to production, where the jettywrapper
  # does not exist and requiring it will fail, and is ok
  puts 'WARNING: JettyWrapper and/or Rubocop was not found and could not be required.'
end

desc 'Run jetty and launch the development Rails server'
task :server do
  unless File.exist? 'jetty'
    Rake::Task['jetty:clean'].invoke
    Rake::Task['spotlight:configure_jetty'].invoke
  end

  jetty_params = Jettywrapper.load_config
  jetty_params[:startup_wait] = 60

  Jettywrapper.wrap(jetty_params) do
    system 'bundle exec rake spotlight:seed'

    unless File.exist? 'tmp/.initialized'
      system 'bundle exec rake spotlight:initialize'
      File.open('tmp/.initialized', 'w') {}
    end
    system 'bundle exec rails s'
  end
end

namespace :spotlight do
  desc 'Copies the default SOLR config for the bundled Testing Server'
  task :configure_jetty do
    FileList['solr_conf/conf/*'].each do |f|
      cp("#{f}", 'jetty/solr/blacklight-core/conf/', verbose: true)
    end
  end

  task seed: [:environment] do
    docs = JSON.parse(File.read(File.join(Rails.root, 'spec', 'fixtures', 'sample_solr_docs.json')))
    conn = Blacklight.default_index.connection
    conn.add docs
    conn.commit
  end
end
