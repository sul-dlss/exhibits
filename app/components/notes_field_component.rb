# frozen_string_literal: true

# Renders general notes; multiple notes are rendered as an unordered list
class NotesFieldComponent < Blacklight::MetadataFieldComponent
  def render_field_values
    @render_field_values ||= Array(notes).compact_blank
  end

  private

  def notes
    values = @field.values
    return if values.blank?
    return values.first if values.one?

    tag.ul(class: 'general-notes') do
      safe_join(values.map { |note| tag.li(note.html_safe) }) # rubocop:disable Rails/OutputSafety
    end
  end
end
