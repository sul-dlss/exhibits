# frozen_string_literal: true

# Add optimistic locking for sidekiq indexing jobs by making sure
# the current, active job was started on or after the most recently
# requested indexing job
class SidekiqValidityChecker < Spotlight::ValidityChecker
  def mint(resource)
    t = Time.zone.now
    Sidekiq.redis do |c|
      c.setex("indexing-validity-#{resource.to_global_id}", 24.hours.to_i, t)
    end

    t
  end

  def check(resource, validity_token)
    Sidekiq.redis do |c|
      t = c.get("indexing-validity-#{resource.to_global_id}") || Time.zone.at(0)
      validity_token >= t
    end
  end
end
