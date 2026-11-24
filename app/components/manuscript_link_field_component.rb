# frozen_string_literal: true

# Renders a link to the related manuscript record
class ManuscriptLinkFieldComponent < Blacklight::MetadataFieldComponent
  def render_field_values
    @render_field_values ||= Array(manuscript_link).compact_blank
  end

  private

  def manuscript_link
    druid = @field.values.first
    return if druid.blank?

    link_to link_title(druid), helpers.spotlight.exhibit_solr_document_path(helpers.current_exhibit, druid)
  end

  def link_title(druid)
    document = @field.document
    title = document['title_display']

    if document.canvas? && title.include?(':')
      title.partition(':')[2]
    else
      druid
    end
  end
end
