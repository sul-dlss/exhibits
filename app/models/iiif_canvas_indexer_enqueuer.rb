# frozen_string_literal: true

##
# For a given object in an exhibit, gets the correct manifest, and enqueues
# canvas/page indexing jobs from that manifest.
class IiifCanvasIndexerEnqueuer
  attr_reader :exhibit, :druid

  ANNOTATION_LIST = 'sc:AnnotationList'.freeze

  def initialize(exhibit, druid)
    @exhibit = exhibit
    @druid = druid
  end

  def enqueue_jobs
    canvases.each do |canvas|
      canvas.other_content.each do |other_content|
        # Don't bother to index unless there is an annotationList content to do so.
        next unless other_content['@type'] == ANNOTATION_LIST
        IndexCanvasJob.perform_later(other_content['@id'], canvas.to_json, exhibit)
      end
    end
  end

  private

  def document
    ##
    # TODO: Often times the document is not yet commited. Not sure if we can
    # ensure this. At the moment, we just rely on job framework / retry.
    @document ||= SolrDocument.find(druid)
  end

  def manifest_url
    document.exhibit_specific_manifest(exhibit.required_viewer.custom_manifest_pattern)
  end

  def canvases
    return [] unless manifest_url
    @canvases ||= IiifManifestHarvester.new(manifest_url).canvases
  end
end
