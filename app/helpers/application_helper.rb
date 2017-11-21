# frozen_string_literal: true

# :nodoc:
module ApplicationHelper
  # Collection titles are indexed as a compound druid + title; we need to
  # unmangle it for display.
  def collection_title(value, separator: '-|-')
    value.split(separator).last
  end

  def document_collection_title(value:, **)
    Array(value).map { |v| collection_title(v) }.to_sentence
  end

  def document_leaflet_map(document:, **)
    render_document_partial(document, 'show_leaflet_map_wrapper')
  end

  ##
  # @param [String] manifest
  def iiif_drag_n_drop(manifest, width: '40px')
    link_url = format Settings.iiif_dnd_base_url, query: { manifest: manifest }.to_query
    link_to link_url, class: 'iiif-dnd pull-right', data: { turbolinks: false } do
      image_tag 'iiif-drag-n-drop.svg', width: width, alt: 'IIIF Drag-n-drop'
    end
  end

  def notes_wrap(options = {})
    return if options[:value].blank?
    return options[:value].first if options[:value].count == 1
    content_tag('ul', class: 'general-notes') do
      safe_join(options[:value].collect do |note|
        content_tag('li', note.html_safe)
      end)
    end
  end

  def table_of_contents_separator(options = {})
    return if options[:value].blank?
    contents = options[:value][0].split('--').map(&:strip)
    return contents.join if contents.length == 1
    contents = safe_join(contents.map { |v| "<li>#{v}</li>".html_safe })
    id = options[:document].id
    render partial: 'catalog/table_of_contents', locals: { contents: contents, collapse_id: "collapseToc-#{id}" }
  end

  def manuscript_link(options = {})
    druid = options[:value]
    document = options[:document]
    ms_number = document['manuscript_number_tesim']
    return if druid.blank? || ms_number.blank?
    return druid if document['format_main_ssim'] != ['Page details']
    title = document['title_full_display']
    title = title.include?(':') ? title.partition(':')[2] : ms_number[0]
    link_to title, spotlight.exhibit_solr_document_path(current_exhibit, druid[0])
  end

  ##
  # Renders a viewer for an object with understanding of the context. In the
  # context of spotlight/catalog render the configured viewer. In other contexts
  # (feature page) render the default viewer
  # @param [SolrDocument] document
  def render_viewer_in_context(document)
    if params[:controller] == 'spotlight/catalog'
      render current_exhibit.required_viewer, document: document
    else
      render current_exhibit.required_viewer.default_viewer_path, document: document
    end
  end
end
