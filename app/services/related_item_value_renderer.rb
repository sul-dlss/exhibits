# frozen_string_literal: true

# Subclass of ModsDisplay::NestedRelatedItem::ValueRenderer to render
# nested related items from MODS with the title wrapped in a <summary> tag
class RelatedItemValueRenderer < ModsDisplay::NestedRelatedItem::ValueRenderer
  def render
    [title, body].compact.join
  end

  private

  def title
    title = Array.wrap(mods_display_html.title).first
    return title if body.blank?

    "<summary>#{title}</summary>"
  end

  def body
    @body ||= body_presence(mods_display_html.body)
  end
end
