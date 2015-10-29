module ModsDocument
  def self.extended(document)
    ModsDocument.register_export_formats(document)
  end

  def self.register_export_formats(document)
    document.will_export_as(:mods)
  end

  def export_as_mods
    self[:modsxml]
  end
end
