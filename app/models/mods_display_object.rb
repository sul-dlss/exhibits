# frozen_string_literal: true

##
# A convenience object useful in SolrDocument for using the mods_display gem,
# ported over from Purl https://github.com/sul-dlss/purl/blob/master/app/models/mods_display_object.rb
class ModsDisplayObject
  include ModsDisplay::ModelExtension
  include ModsDisplay::ControllerExtension

  attr_reader :xml

  def initialize(xml)
    @xml = xml
  end

  def modsxml
    @xml
  end

  mods_xml_source(&:xml)
end
