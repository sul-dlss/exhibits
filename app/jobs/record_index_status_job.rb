# Record the status of an index job
class RecordIndexStatusJob < ActiveJob::Base
  def perform(harvester, druid, index_status = {})
    s = sidecar(harvester, druid)

    s.update(index_status: index_status.merge(timestamp: Time.zone.now))
  end

  def sidecar(harvester, id)
    type = harvester.exhibit.blacklight_config.document_model.model_name.name
    harvester.exhibit.solr_document_sidecars.find_or_initialize_by(document_id: id, document_type: type) do |sidecar|
      sidecar.resource = harvester
    end
  end
end
