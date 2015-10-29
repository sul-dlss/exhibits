set :output, File.join('log', 'cron.log')
#
# every :day, :at => '2:30am', :roles => [:app] do
#   rake "spotlight:reindex"
# end
#
# every 1.day, :at => '5:00 am' do
#   rake "-s sitemap:refresh"
# end
