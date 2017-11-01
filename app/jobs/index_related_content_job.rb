# frozen_string_literal: true

# Index related things for an SDR object.
class IndexRelatedContentJob < ActiveJob::Base
  def perform(harvester, druid)
    IiifCanvasIndexerEnqueuer.new(harvester.exhibit, druid).enqueue_jobs
  end
end
