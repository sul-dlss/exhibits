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
end
