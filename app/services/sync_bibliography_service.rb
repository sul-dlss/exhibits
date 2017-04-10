# A Bibliography service that right now is only a Zotero implementation
class SyncBibliographyService
  attr_reader :exhibit
  def initialize(exhibit)
    @exhibit = exhibit
    validate
  end

  def sync
    resources.each do |resource|
      resource.solr_document_sidecars.each do |sidecar|
        sync_resource(resource, sidecar)
      end
    end

    exhibit.bibliography_service.mark_as_updated!
  end

  def validate
    if exhibit.bibliography_service.blank?
      raise ArgumentError, 'The provided exhibit did not have a properly configured bibliography service.'
    elsif exhibit.resources.blank?
      raise ArgumentError, 'The provided exhibit did not have any resources.'
    end
  end

  private

  delegate :bibliography_service, :resources, to: :exhibit

  def sync_resource(resource, sidecar)
    document_id = sidecar.document_id
    bibliography = bibliography_api.bibliography_for(document_id)
    # If the document has a bibliography associated with it but the API doesn't return one
    # then we should delete the document's bibliography as it has been "untagged" in the API
    if bibliography.nil? && sidecar.data[solr_document_field].present?
      sidecar.data[solr_document_field] = nil
      sidecar.save
      resource.reindex_later
    # Otherwise if the bibliography is present render it
    elsif bibliography
      sidecar.data[solr_document_field] = bibliography.render
      sidecar.save
      resource.reindex_later
    end
  end

  def solr_document_field
    Settings.zotero_api.solr_document_field
  end

  def bibliography_api
    @bibliography_api ||= ZoteroApi::Client.new(
      id: bibliography_service.api_id,
      type: bibliography_service.api_type
    )
  end
end
