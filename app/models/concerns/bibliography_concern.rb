##
# A concern to be mixed into SolrDocument for accessing a document's
# bibliography
module BibliographyConcern
  def bibliography
    @bibliography ||= fetch(Settings.zotero_api.solr_document_field, []).collect do |bib_item|
      DocumentBibliography.new(bib_item)
    end
  end
end
