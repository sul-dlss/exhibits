# frozen_string_literal: true

# Add optimistic locking for sidekiq indexing jobs by making sure
# the current, active job was started on or after the most recently
# requested indexing job
class SidekiqValidityChecker < Spotlight::ValidityChecker
  def mint(job)
    t = serialize(Time.zone.now)

    Sidekiq.redis do |c|
      c.setex("indexing-validity-#{job.arguments.first.to_global_id}", 24.hours.to_i, t)
    end

    t
  end

  def check(job, validity_token)
    Sidekiq.redis do |c|
      stored_token = c.get("indexing-validity-#{job.arguments.first.to_global_id}")

      t = deserialize(stored_token) if stored_token
      t ||= Time.zone.at(0)

      deserialize(validity_token) >= t
    end
  end

  private

  def serialize(value)
    value.to_i.to_s
  end

  def deserialize(str)
    Time.zone.at(str.to_s.to_i)
  end
end
