# frozen_string_literal: true

# Persist JSON resources and index them
class CreateResourceJob < ActiveJob::Base
  queue_as :default

  def perform(id, exhibit, json, metadata = {})
    resource = Spotlight::Resource.find_or_initialize_by(url: id, exhibit_id: exhibit.id)
    resource.attributes = { json: json, metadata: metadata }
    unless resource.save
      logger.warn "Unable to save resource #{id} because: #{resource.errors.full_messages}"
      return
    end
    resource.reindex
  end
end
