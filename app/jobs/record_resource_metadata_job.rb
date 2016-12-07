# Record the metadata for an index job
class RecordResourceMetadataJob < ActiveJob::Base
  def perform(resource)
    resource.update_collection_metadata!
  end
end
