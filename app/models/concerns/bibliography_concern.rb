##
# A concern to be mixed into SolrDocument for accessing a document's
# bibliography
module BibliographyConcern
  def bibliography
    fetch(Settings.zotero_api.solr_document_field, nil)
  end

  def reference?
    fetch('format_main_ssim', []).first == 'Reference'
  end

  def bibtex
    BibTeX.parse(first('bibtex_ts')) if reference?
  end

  def formatted_bibliography
    first('formatted_bibliography_ts') if reference?
  end
end
