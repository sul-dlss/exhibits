# frozen_string_literal: true

##
# Convenience methods for metadata access
module MetadataConcern
  def modsxml
    fetch(:modsxml, nil)
  end

  ##
  # Convenience method for accessing cached / parsed modsxml using
  # ModsDisplay
  def mods
    @mods ||= mods_display_object.mods_display_html
  end

  private

  def mods_display_object
    @mods_display_object ||= ModsDisplay::Record.new(modsxml)
  end
end
