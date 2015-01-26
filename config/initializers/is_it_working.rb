require 'is_it_working'

Rails.configuration.middleware.use(IsItWorking::Handler) do |h|
  # Check the ActiveRecord database connection without spawning a new thread
  h.check :active_record, :async => false

  h.check :rsolr, client: Blacklight.solr
end