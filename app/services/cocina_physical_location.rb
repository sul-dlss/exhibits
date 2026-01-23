# frozen_string_literal: true

# Class to handle Cocina physical location information
class CocinaPhysicalLocation
  def initialize(cocina_record:)
    @cocina_record = cocina_record
  end

  def box
    return unless physical_location

    physical_location.match(/Box ?:? ?([^,|(Folder)]+)/i)&.[](1)&.strip
  end

  def folder
    return unless physical_location

    # pipe-delimited entries may contain commas within values
    # comma-delimited may NOT contain commas within values
    regex = physical_location.include?('|') ? /Folder ?:? ?([^|]+)/i : /Folder ?:? ?([^,]+)/i
    physical_location.match(regex)&.[](1)&.strip
  end

  def series
    return unless physical_location

    # feigenbaum uses 'Accession'
    physical_location.match(/(?:(?:Series)|(?:Accession)):? ([^,|]+)/i)&.[](1)&.strip
  end

  def physical_location
    @physical_location ||= physical_locations.find { it.match?(/.*(Series)|(Accession)|(Folder)|(Box).*/i) }
  end

  private

  def physical_locations
    @physical_locations ||= accesses + related_accesses
  end

  def accesses
    @cocina_record.accesses.map(&:to_s)
  end

  def related_accesses
    @cocina_record.related_resources.flat_map { it.accesses.map(&:to_s) }
  end
end
