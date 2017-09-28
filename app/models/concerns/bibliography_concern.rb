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
    BibTeX.parse(fetch('bibtex_ts', []).first) if reference?
  end

  def formatted_bibliography
    fetch('formatted_bibliography_ts', []).first if reference?
    # TODO: for non-reference resources we'll generate a bibliography for them
  end
end
