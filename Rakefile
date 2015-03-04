# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

task :default => [:ci]

SulExhibitsTemplate::Application.load_tasks

ZIP_URL = "https://github.com/projectblacklight/blacklight-jetty/archive/v4.10.3.zip"
require 'jettywrapper'



require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)


task :ci => ['jetty:clean', 'spotlight:configure_jetty'] do
  ENV['environment'] = "test"
  jetty_params = Jettywrapper.load_config
  jetty_params[:startup_wait]= 60

  Jettywrapper.wrap(jetty_params) do
    # run the tests
    Rake::Task["spec"].invoke
  end
end



namespace :spotlight do
  desc "Copies the default SOLR config for the bundled Testing Server"
  task :configure_jetty do
    FileList['solr_conf/conf/*'].each do |f|  
      cp("#{f}", 'jetty/solr/blacklight-core/conf/', :verbose => true)
    end
  end
end