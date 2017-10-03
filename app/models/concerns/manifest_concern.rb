##
# A concern to be mixed into the SolrDocument class in order to provide
# convenient accessors for IIIF manifests embeded in a SolrDocument
module ManifestConcern
  def manifest
    fetch('iiif_manifest_url_ssi', nil)
  end
end
