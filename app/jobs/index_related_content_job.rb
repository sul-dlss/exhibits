# frozen_string_literal: true

# Index related things for an SDR object.
class IndexRelatedContentJob < ActiveJob::Base
  def perform(harvester, druid)
    related_iiif_annotations(harvester, druid)
  end

  def related_iiif_annotations(harvester, druid)
    # TODO: Often times the document is not yet commited. Not sure if we can ensure this.
    document = SolrDocument.find(druid)
    manifest_url = document.exhibit_specific_manifest(harvester.exhibit.required_viewer.custom_manifest_pattern)
    canvases = IiifManifestHarvester.new(manifest_url, document.id).canvases
    canvases.each do |canvas|
      canvas.other_content.each do |other_content|
        # Don't bother to index unless there is an annotationList content to do so.
        next unless other_content['@type'] == 'sc:AnnotationList'
        IndexCanvasJob.perform_later(other_content['@id'], canvas.to_json, harvester.exhibit)
      end
    end
  end
end
