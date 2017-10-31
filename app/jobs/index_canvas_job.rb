# frozen_string_literal: true

##
# Used to kick off the CanvasResource
class IndexCanvasJob < ActiveJob::Base
  def perform(id, canvas, exhibit)
    canvas_resource = CanvasResource.find_or_initialize_by(url: id, exhibit: exhibit)
    canvas_resource.data = JSON.parse(canvas)
    canvas_resource.save
    canvas_resource.reindex
  end
end
