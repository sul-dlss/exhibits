# frozen_string_literal: true

##
# Model for a IIIF Canvas that contains only a set of annotations
class Canvas
  attr_reader :id, :iiif_id, :label, :annotation_lists, :annotations
  delegate :size, to: :annotations

  # @param [String] `id`, `iiif_id`, `label`
  # @param [Array<String>] `annotation_lists` is a list of URLs to IIIF AnnotationList data
  # @param [Array<String>] `annotations` is a list of text annotations
  def initialize(id, iiif_id, label, annotation_lists, annotations)
    @id = id
    @iiif_id = iiif_id
    @label = label
    @annotation_lists = annotation_lists
    @annotations = annotations
  end

  def type
    'sc:Canvas'
  end
end
