# frozen_string_literal: true

# :nodoc:
module MetadataHelper
  ##
  # Splits and modifies ModsDisplay::Values objects for whitespace
  def mods_value_white_space_splitter!(mods_values)
    mods_values.values = mods_values.values.map { |v| v.gsub('&#10;', "\n").split("\n") }.flatten.compact
    mods_values
  end
end
