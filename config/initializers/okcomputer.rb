# override the default behavior so we can override the root engine path to run all checks
OkComputer.mount_at = false

OkComputer::Registry.register "version", OkComputer::AppVersionCheck.new
OkComputer::Registry.register "cache", OkComputer::CacheCheck.new
OkComputer::Registry.register "background_jobs", OkComputer::SidekiqLatencyCheck.new('default', 50)
OkComputer::Registry.register "solr", OkComputer::HttpCheck.new(Blacklight.default_index.connection.uri.to_s.sub(/\/$/, '') + "/admin/ping")

class SidekiqRetryQueueCheck < OkComputer::Check
  def check
    if sidekiq_retry_size > sidekiq_retry_size_threshold
      mark_failure
      mark_message "Sidekiq retry queue size (#{sidekiq_retry_size}) is above the threshold (#{sidekiq_retry_size_threshold})"
    else
      mark_message "Sidekiq retry queue size (#{sidekiq_retry_size}) is below the threshold (#{sidekiq_retry_size_threshold})"
    end
  rescue => e
    mark_failure
    mark_message "Unable to check sidekiq retry queue size with error: #{e}"
  end

  private

  def sidekiq_retry_size
    Sidekiq::Stats.new.retry_size.to_i
  end

  def sidekiq_retry_size_threshold
    Settings.sidekiq_retry_queue_threshold.to_i
  end
end

OkComputer::Registry.register 'sidekiq-retry', SidekiqRetryQueueCheck.new

OkComputer.make_optional %w(version cache background_jobs sidekiq-retry)
