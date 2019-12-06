# frozen_string_literal: true

# Record the status of an index job
class RecordIndexStatusJob < ApplicationJob
  def perform(harvester, druid, index_status = {})
    type = harvester.exhibit.blacklight_config.document_model.model_name.name
    s = create_or_find_sidecar(relation(harvester), document_id: druid, document_type: type)

    s.update(resource: harvester, index_status: index_status.merge(timestamp: Time.zone.now))
  end

  private

  # Inspired by Rails 6's create_or_find_by method
  def create_or_find_sidecar(relation, attributes = {})
    relation.transaction(requires_new: true) do
      relation.create(attributes)
    end
  rescue ActiveRecord::RecordNotUnique
    relation.find_by!(attributes)
  end

  def relation(harvester)
    harvester.exhibit.solr_document_sidecars
  end
end
