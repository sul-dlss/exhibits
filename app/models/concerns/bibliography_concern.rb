# frozen_string_literal: true

##
# A concern to be mixed into SolrDocument for accessing a document's
# bibliography
module BibliographyConcern
  def reference?
    first('format_main_ssim') == 'Reference'
  end

  def cites_other_documents?
    !related_document_ids.empty?
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

  def bibliography_url
    first('bibtex_key_ss') if reference?
  end

  def zotero_url
    return unless reference?

    begin
      url = URI.parse(bibliography_url)
      # rubocop:disable  Performance/RegexpMatch
      url.to_s if url.host =~ /zotero/i
      # rubocop:enable  Performance/RegexpMatch
    rescue URI::InvalidURIError
      nil # just a regular BibTeX key
    end
  end
end
