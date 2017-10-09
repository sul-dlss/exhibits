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

  def bibtex_notes(value, separator: ',')
    byebug
    value = @document["general_notes_ssim"][0].split(separator)
    notes = []
    value.each do |note|
      notes << "<li>#{note}<li>"
    end
    "<ul>#{notes.flatten}
    </ul>"
  end
end
