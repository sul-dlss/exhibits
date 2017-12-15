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

  # @note thumbnail handling moves to a presenter in Blacklight 7.
  # Overriding Blacklight to provide a default thumbnail for references.
  # Need to override instead of configuring a thumbnail_method because thumbnail_method
  # does not receive url_options to be passed to a link_to_document
  #
  # @param [SolrDocument] document
  # @param [Hash] image_options to pass to the image tag
  # @param [Hash] url_options to pass to #link_to_document
  # @return [String]
  def render_thumbnail_tag(document, image_options = {}, url_options = {})
    return super unless document.reference? || document.canvas?
    image = image_tag(thumbnail_tag_image_path(document), image_options)
    link_to_document document, image, url_options
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

  def render_fulltext_highlight(args)
    return if args[:value].blank?
    safe_join(args[:value].map do |val|
      content_tag('p') do
        val
      end
    end, '')
  end

  private

  def thumbnail_tag_image_path(document)
    if document.reference?
      blacklight_config.view_config(document_index_view_type).default_bibliography_thumbnail
    elsif document.canvas?
      blacklight_config.view_config(document_index_view_type).default_canvas_thumbnail
    end
  end
end
