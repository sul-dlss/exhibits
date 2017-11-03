# frozen_string_literal: true

# Index related things for an SDR object.
class IndexRelatedContentJob < ActiveJob::Base
  def perform(harvester, druid)
    IiifCanvasIndexer.new(harvester.exhibit, druid).index_canvases
  end
end
