# frozen_string_literal: true

# Custom upload solr document builder that adds square thumbnail urls
class UploadSolrDocumentBuilder < Spotlight::UploadSolrDocumentBuilder
  def add_file_versions(solr_hash)
    super(solr_hash)

    solr_hash[:thumbnail_square_url_ssm] = riiif.image_path(resource.upload_id, region: 'square', size: '100,100')
  end
end
