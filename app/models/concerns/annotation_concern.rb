# frozen_string_literal: true

##
# A concern to be mixed into SolrDocument for accessing a document's
# annotation
module AnnotationConcern
  def annotation?
    first('format_main_ssim') == 'Annotation'
  end

  # @return [Annotation]
  def annotation
    return unless annotation?
    Annotation.new(
      id,
      first('annotation_tesim'),
      Annotation::Target.new(
        first('xywh_ssim'),
        first('canvas_ssim'),
        first('related_document_id_ssim')
      ),
      language: first('language'),
      motivation: first('motivation_ssim')
    )
  end
end
