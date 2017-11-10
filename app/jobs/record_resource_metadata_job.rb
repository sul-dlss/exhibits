# Record the metadata for an index job
class RecordResourceMetadataJob < ApplicationJob
  def perform(resource)
    resource.update_collection_metadata!
  end
end
