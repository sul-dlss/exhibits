# override the default behavior so we can override the root engine path to run all checks
OkComputer.mount_at = false

OkComputer::Registry.register "version", OkComputer::AppVersionCheck.new
OkComputer::Registry.register "cache", OkComputer::CacheCheck.new
OkComputer::Registry.register "delayed_jobs", OkComputer::DelayedJobBackedUpCheck.new(10, 50)
OkComputer::Registry.register "solr", OkComputer::SolrCheck.new(Blacklight.default_index.connection.uri.to_s)

OkComputer.make_optional %w(version cache delayed_jobs)
