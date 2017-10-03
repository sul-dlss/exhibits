##
# A concern to be mixed into SolrDocument for accessing a document's
# bibliography
module BibliographyConcern
  def reference?
    first('format_main_ssim') == 'Reference'
  end

  def bibtex
    BibTeX.parse(first('bibtex_ts')) if reference?
  end

  def formatted_bibliography
    first('formatted_bibliography_ts') if reference?
  end

  def related_document_ids
    fetch('related_document_id_ssim', []) if reference?
  end
end
