# frozen_string_literal: true

##
# Class for handling BibliographyResourcesController
class BibliographyFormattingController < ApplicationController
  def show
    bibliography_ids = Array.wrap(params.require(:id))
    bibtex = bibliography_ids.collect do |document_id|
      SolrDocument.find(document_id).bibtex.to_s
    end.join("\n")
    render html: Bibliography.new(bibtex).to_html.html_safe # rubocop: disable Rails/OutputSafety
  end
end
