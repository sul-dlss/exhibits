# frozen_string_literal: true

# Subclass of ModsDisplay::NestedRelatedItem::ValueRenderer to render
# nested related items from MODS with the title wrapped in a <summary> tag
class RelatedItemValueRenderer < ModsDisplay::NestedRelatedItem::ValueRenderer
  def render
    [title, body_presence(mods_display_html.body)].compact.join
  end

  private

  def title
    "<summary>#{Array.wrap(mods_display_html.title).first}</summary>"
  end
end
