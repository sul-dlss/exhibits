# frozen_string_literal: true

##
# Override of Blacklight's CatalogHelper to override our own methods
module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  # @note thumbnail handling moves to a presenter in Blacklight 7.
  # Overriding Blacklight so that all references display thumbnails
  #
  # @param [SolrDocument] document
  # @return [Boolean]
  # rubocop:disable Naming/PredicateName
  def has_thumbnail?(document)
    return super unless document.reference? || document.canvas?

    true
  end
  # rubocop:enable Naming/PredicateName

  def exhibits_default_thumbnail(document, image_options)
    if document.reference?
      image_tag(
        blacklight_config.view_config(document_index_view_type).default_bibliography_thumbnail,
        image_options
      )
    elsif document.canvas?
      image_tag(
        blacklight_config.view_config(document_index_view_type).default_canvas_thumbnail,
        image_options
      )
    end
  end

  def notes_wrap(options = {})
    return if options[:value].blank?
    return options[:value].first if options[:value].count == 1

    content_tag('ul', class: 'general-notes') do
      safe_join(options[:value].collect do |note|
        content_tag('li', note.html_safe) # rubocop:disable Rails/OutputSafety
      end)
    end
  end

  def table_of_contents_separator(options = {})
    return if options[:value].blank?

    contents = options[:value][0].split('--').map(&:strip)
    return contents.join if contents.length == 1
    return contents if request.format.json?

    contents = safe_join(contents.map { |v| "<li>#{v}</li>".html_safe }) # rubocop:disable Rails/OutputSafety
    id = options[:document].id
    render partial: 'catalog/table_of_contents', locals: { contents: contents, collapse_id: "collapseToc-#{id}" }
  end

  def manuscript_link(options = {})
    return if options[:value].blank?

    druid = options[:value][0]
    document = options[:document]
    title = document['title_full_display']
    link_title = if document.canvas? && title.include?(':')
                   title.partition(':')[2]
                 else
                   druid
                 end
    link_to link_title, spotlight.exhibit_solr_document_path(current_exhibit, druid)
  end

  def search_for_doc_text_link(document)
    return '' unless params[:q] && document[:druid]

    link_to(
      "Search for \"#{params[:q]}\" in document text",
      spotlight.exhibit_solr_document_path(current_exhibit, document[:druid], search: params[:q]),
      class: 'prepared-search-link'
    )
  end

  def render_fulltext_highlight(document:, **_args)
    highlights = document.full_text_highlights

    link = search_for_doc_text_link(document)

    safe_join(highlights.take(Settings.full_text_highlight.snippet_count).map do |val|
      content_tag('p') do
        sanitize(val, tags: %w(em))
      end
    end.prepend(link), '')
  end
end
