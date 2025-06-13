# frozen_string_literal: true

# Returns the MODS XML for a PURL either from the supplied public XML or
# by fetching the MODS document directly from PURL.
class PurlModsService
  # @param public_xml [Nokogiri::XML::Document] the Purl public XML document
  # @return [Nokogiri::XML::Document] the MODS XML document
  # @example
  #   PurlModsService.call(public_xml)
  def self.call(public_xml)
    new(public_xml).mods_xml
  end

  # @param public_xml [Nokogiri::XML::Document] the public XML document
  # @example
  #   PurlModsService.new(public_xml)
  def initialize(public_xml)
    @public_xml = public_xml
  end

  # @return [Nokogiri::XML::Document] the MODS XML document
  def mods_xml
    @mods_xml ||= if mods_xpath.any?
                    mods_xpath.first
                  else
                    send_fallback_notification!
                    Nokogiri::XML(mods_response_body)
                  end
  end

  private

  def mods_xpath
    @mods_xpath ||= @public_xml.xpath('/publicObject/mods:mods', mods: 'http://www.loc.gov/mods/v3')
  end

  def mods_response_body
    PurlService.new(druid, format: :mods).response_body
  end

  def send_fallback_notification!
    return unless defined?(Honeybadger)

    Honeybadger.notify(
      'Unable to find MODS in the public xml; falling back to stand-alone mods document',
      context: { druid: druid }
    )
  end

  def druid
    @druid ||= @public_xml.xpath('/publicObject/@id').text.delete_prefix('druid:')
  end
end
