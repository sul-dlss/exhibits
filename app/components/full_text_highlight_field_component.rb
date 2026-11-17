# frozen_string_literal: true

# Renders the full text highlight snippets for a document, along with a link
# to search within the document's full text
class FullTextHighlightFieldComponent < Blacklight::MetadataFieldComponent
  def render_field_values
    @render_field_values ||= Array(highlights).compact_blank
  end

  private

  def document
    @field.document
  end

  def highlights
    snippets = document.full_text_highlights.take(Settings.full_text_highlight.snippet_count).map do |val|
      tag.p(sanitize(val, tags: %w(em)))
    end

    contents = safe_join(snippets.prepend(search_for_doc_text_link), '')
    return if contents.blank?

    tag.div(contents, data: { controller: 'full-text-collapse' })
  end

  def search_for_doc_text_link
    query = helpers.params[:q]
    return '' unless query && document[:druid]

    link_to(
      "Search for \"#{query}\" in document text",
      helpers.spotlight.exhibit_solr_document_path(helpers.current_exhibit, document[:druid], search: query),
      class: 'prepared-search-link'
    )
  end
end
