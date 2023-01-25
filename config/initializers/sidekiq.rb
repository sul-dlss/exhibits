Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('SIDEKIQ_REDIS_URL', "redis://localhost:6379/1") }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('SIDEKIQ_REDIS_URL', "redis://localhost:6379/1") }
end

if ENV['JOB_STATUS_REDIS_URL']
  # Shared activejob status reporting 
  ActiveJob::Status.store = ActiveSupport::Cache::RedisCacheStore.new(url: ENV.fetch('JOB_STATUS_REDIS_URL'))
end