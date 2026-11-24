# frozen_string_literal: true

# Renders the exhibit slugs index field in search-across results as links to
# the document within each accessible exhibit, flagging unpublished exhibits.
class ExhibitTitleFieldComponent < Blacklight::MetadataFieldComponent
  def render_field_values
    @render_field_values ||= [exhibit_links].compact_blank
  end

  private

  def exhibit_links
    links = helpers.exhibit_metadata.slice(*@field.values).values.map do |x|
      link = link_to(x['title'] || x['slug'],
                     helpers.spotlight.exhibit_solr_document_path(x['slug'], @field.document.id))
      badge = render(UnpublishedBadgeComponent.new(class: 'ms-1')) unless x['published']

      safe_join([link, badge], ' ')
    end
    safe_join links, tag.br
  end
end
