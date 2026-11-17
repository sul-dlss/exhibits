# frozen_string_literal: true

# Renders a (sanitized) field value, splitting embedded line breaks into paragraphs
class ParagraphFieldComponent < Blacklight::MetadataFieldComponent
  # Which tags do we accept in the metadata.
  # From https://github.com/sul-dlss/mods_display/blob/2c7b6faef791e7d0d6ae27711bfc7687e1c0dc3d/app/helpers/mods_display/record_helper.rb#L74
  # And also the "p" tag.
  PERMITTED_TAGS = %w(a dl dd dt i b em strong cite br p).freeze

  # Used as the field's `values:` config so that every consumer of the field (this component,
  # the JSON API, Spotlight captions) gets the split and sanitized paragraphs.
  # @return [Array<ActiveSupport::SafeBuffer>]
  def self.values(field_config, document, _view_context = nil)
    split_on_white_space(Array(document.fetch(field_config.field, nil)))
      .map { |value| ActionController::Base.helpers.sanitize(value, tags: PERMITTED_TAGS) }
  end

  ##
  # Splits an array of strings on internal whitespace breaks
  def self.split_on_white_space(values)
    values.map { |v| v.gsub('&#10;', "\n").split("\n") }.flatten.compact
  end

  def render_field_values
    @render_field_values ||= Array(paragraphs).compact_blank
  end

  private

  def paragraphs
    values = @field.values
    return if values.blank?
    return values.first if values.one?

    safe_join(values.map { |content| tag.p content })
  end
end
