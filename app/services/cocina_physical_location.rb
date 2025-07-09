# frozen_string_literal: true

# Class to handle Cocina physical location information
class CocinaPhysicalLocation
  def initialize(cocina_record:)
    @cocina_record = cocina_record
  end

  def box
    physical_locations.each do |location|
      match_data = location.match(/Box ?:? ?([^,|(Folder)]+)/i) # NOTE: this will also find Flatbox or Flat-box
      return match_data[1].strip if match_data.present?
    end
    nil
  end

  def folder
    physical_locations.each do |location|
      match_data = if location.include?('|')
                     # expect pipe-delimited, may contain commas within values
                     location.match(/Folder ?:? ?([^|]+)/)
                   else
                     # expect comma-delimited, may NOT contain commas within values
                     location.match(/Folder ?:? ?([^,]+)/)
                   end
      return match_data[1].strip if match_data.present?
    end
    nil
  end

  def physical_location_str
    physical_locations.find do |location|
      location =~ /.*(Series)|(Accession)|(Folder)|(Box).*/i
    end
  end

  def series
    physical_locations.each do |location|
      # feigenbaum uses 'Accession'
      match_data = location.match(/(?:(?:Series)|(?:Accession)):? ([^,|]+)/i)
      return match_data[1].strip if match_data.present?
    end
    nil
  end

  private

  def physical_locations
    @physical_locations ||= access_locations + related_item_locations + digital_locations + related_digital_locations
  end

  def related_item_locations
    @cocina_record.path('$.description.relatedResource.*.access.physicalLocation[?(@.value)].value').to_a
  end

  def access_locations
    @cocina_record.path('$.description.access.physicalLocation[?(@.value)].value').to_a
  end

  def related_digital_locations
    @cocina_record.path('$.description.relatedResource.*.access.digitalLocation[?(@.value)].value').to_a
  end

  def digital_locations
    @cocina_record.path('$.description.access.digitalLocation[?(@.value)].value').to_a
  end
end
