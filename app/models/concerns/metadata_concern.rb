# frozen_string_literal: true

##
# Convenience methods for metadata access
module MetadataConcern
  def modsxml
    fetch(:modsxml, nil)
  end

  ##
  # Convenience method for accessing cached / parsed modsxml using
  # ModsDisplay::ControllerExtension#render_mods_display
  def mods
    @mods ||= begin
      mods_display_object.render_mods_display(mods_display_object)
    end
  end

  private

  def mods_display_object
    @mods_display_object ||= ModsDisplayObject.new(modsxml)
  end
end
