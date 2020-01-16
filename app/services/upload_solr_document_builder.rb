# frozen_string_literal: true

# Custom upload solr document builder that adds square thumbnail urls
class UploadSolrDocumentBuilder < Spotlight::UploadSolrDocumentBuilder
  def add_file_versions(solr_hash)
    super(solr_hash)

    solr_hash[:thumbnail_square_url_ssm] = riiif.image_path(resource.upload_id, region: 'square', size: '100,100')
  end

  # Override upstream to add an empty locale
  def add_manifest_path(solr_hash)
    path = spotlight_routes.manifest_exhibit_solr_document_path(exhibit, resource.compound_id, locale: nil)
    solr_hash[Spotlight::Engine.config.iiif_manifest_field] = path
  end
end
