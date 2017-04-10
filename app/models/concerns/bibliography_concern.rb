##
# A concern to be mixed into SolrDocument for accessing a document's
# bibliography
module BibliographyConcern
  def bibliography
    fetch(Settings.zotero_api.solr_document_field, nil)
  end
end
