# frozen_string_literal: true

# Renders a "--"-separated table of contents as a collapsible list
class TableOfContentsFieldComponent < Blacklight::MetadataFieldComponent
  # Used as the field's `values:` config so that every consumer of the field (this component,
  # the JSON API) gets the individual table of contents entries.
  # @return [Array<String>]
  def self.values(field_config, document, _view_context = nil)
    value = Array(document.fetch(field_config.field, nil)).first
    return [] if value.blank?

    value.split('--').map(&:strip)
  end

  def render_field_values
    @render_field_values ||= Array(table_of_contents).compact_blank
  end

  private

  def table_of_contents
    contents = @field.values
    return if contents.blank?
    return contents.join if contents.one?

    render TableOfContentsListComponent.new(contents:, collapse_id: "collapseToc-#{@field.document.id}")
  end
end
