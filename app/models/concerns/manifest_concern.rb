##
# A concern to be mixed into the SolrDocument class in order to provide
# convenient accessors for IIIF manifests embeded in a SolrDocument
module ManifestConcern
  def manifest
    manifest_url = fetch('iiif_manifest_url_ssi', nil)
    return if manifest_url.blank? || !manifest_available?
    manifest_url
  end

  def exhibit_specific_manifest(custom_manifest_pattern)
    return manifest if custom_manifest_pattern.blank?
    # Return early if there is not a manifest pattern (a heuristic for a non-image thing)
    return manifest if manifest.blank?
    custom_manifest_pattern.gsub('{id}', first('canvas_parent_druid_ssi') || first('id'))
  end

  VALID_IIIF_CONTENT_TYPES = %w(image manuscript map book).freeze

  # even if a URL is present we need to check the contentMetadata type
  # to determine whether the manifest will resolve at runtime.
  def manifest_available?
    VALID_IIIF_CONTENT_TYPES.include?(first('content_metadata_type_ssm').to_s)
  end
end
