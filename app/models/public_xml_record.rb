# frozen_string_literal: true

# Retrieves and represents the public xml file from PURL
class PublicXmlRecord
  attr_reader :druid, :options

  def self.fetch(url)
    response = HTTP.get(url)
    response.body if response.status.ok?
  end

  def initialize(druid, options = {})
    @druid = druid
    @options = options
  end

  def public_xml
    @public_xml ||= self.class.fetch("#{purl_base_url}.xml")
  end

  def public_xml_doc
    @public_xml_doc ||= Nokogiri::XML(public_xml)
  end

  def mods
    @mods ||= if public_xml_doc.xpath('/publicObject/mods:mods', mods: 'http://www.loc.gov/mods/v3').any?
                public_xml_doc.xpath('/publicObject/mods:mods', mods: 'http://www.loc.gov/mods/v3').first
              else
                if defined?(Honeybadger)
                  Honeybadger.notify(
                    'Unable to find MODS in the public xml; falling back to stand-alone mods document',
                    context: { druid: druid }
                  )
                end

                Nokogiri::XML(self.class.fetch("#{purl_base_url}.mods"))
              end
  end

  def purl_base_url
    format(Settings.purl.url, druid:)
  end
end
