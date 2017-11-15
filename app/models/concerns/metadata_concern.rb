# frozen_string_literal: true

##
# Convenience methods for metadata access
module MetadataConcern
  def modsxml
    fetch(:modsxml, nil)
  end
end
