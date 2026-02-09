# frozen_string_literal: true

##
# Blacklight::Document model mixin for delivering MODS XML through
# the Blacklight document extension framework.
module ModsDocument
  def self.extended(document)
    ModsDocument.register_export_formats(document)
  end

  def self.register_export_formats(document)
    document.will_export_as(:mods)
  end

  def export_as_mods
    self[:modsxml] || PurlService.new(self[:druid], format: :mods).response_body
  end
end
