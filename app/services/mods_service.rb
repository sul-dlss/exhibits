# frozen_string_literal: true

# class that either converts MARC records to MODS if that is available and
# injects some additional information from the Cocina, OR returns the MODS from
# the public XML, OR as a last resort fetches the MODS from PURL.
class ModsService
  # @param purl_object [Purl] the PURL object to return MODS XML for
  # @return [Nokogiri::XML::Document] MODS XML
  # @example
  #   ModsService.call(purl_object: Purl.new('druid:abc123'))
  def self.call(purl_object:)
    new(purl_object:).mods_xml
  end

  attr_reader :purl_object

  # @param purl_object [Purl] the PURL object to return MODS XML for
  # @example
  #   ModsService.new(purl_object: Purl.new('druid:abc123'))
  def initialize(purl_object:)
    @purl_object = purl_object
  end

  delegate :public_cocina, :public_xml, to: :purl_object

  # @return [Nokogiri::XML::Document] MODS XML
  def mods_xml
    @mods_xml ||= if catalog_record_id.present?
                    inject_cocina_metadata(mods_from_catalog_record)
                  else
                    PurlModsService.call(public_xml)
                  end
  end

  private

  def mods_from_catalog_record
    @mods_from_catalog_record ||= Nokogiri::XML(ModsFromMarcService.mods(folio_instance_hrid: catalog_record_id))
  end

  def catalog_record_id
    active_refresh_catalog_record&.fetch('catalogRecordId', nil)
  end

  def active_refresh_catalog_record
    @active_refresh_catalog_record ||= public_cocina.dig('identification', 'catalogLinks').find do |record|
      record.fetch('catalog', '') == 'folio' &&
        record.fetch('refresh', '') == true
    end
  end

  def inject_cocina_metadata(mods)
    inject_part_label(mods)
    inject_use_and_reproduction_statement(mods)
    inject_copyright(mods)
    inject_license(mods)
  end

  def inject_part_label(mods)
    return mods if part_label_for_serials.blank?

    title_info = mods.at_xpath('//mods:mods/mods:titleInfo', 'mods' => 'http://www.loc.gov/mods/v3')
    title_info.search('//mods:partNumber', 'mods' => 'http://www.loc.gov/mods/v3').remove
    title_info.search('//mods:partName', 'mods' => 'http://www.loc.gov/mods/v3').remove
    title_info.add_child("<partNumber>#{part_label_for_serials}</partNumber>")
    mods
  end

  def inject_copyright(mods)
    return mods if copyright.blank?

    mods_xpath(mods).add_child("<accessCondition type=\"copyright\">#{copyright}</accessCondition>")
    mods
  end

  def inject_use_and_reproduction_statement(mods)
    return mods if use_and_reproduction_statement.blank?

    mods_xpath(mods)
      .add_child("<accessCondition type=\"useAndReproduction\">#{use_and_reproduction_statement}</accessCondition>")
    mods
  end

  def inject_license(mods)
    return mods if license_url.blank?

    description = LicenseService.call(url: license_url)

    mods_xpath(mods)
      .add_child("<accessCondition type=\"license\" xlink:href=\"#{license_url}\">#{description}</accessCondition>")
    mods
  end

  def part_label_for_serials
    active_refresh_catalog_record&.fetch('partLabel', nil)
  end

  def use_and_reproduction_statement
    public_cocina.dig('access', 'useAndReproductionStatement')
  end

  def copyright
    public_cocina.dig('access', 'copyright')
  end

  def license_url
    public_cocina.dig('access', 'license')
  end

  def mods_xpath(mods)
    mods.at_xpath('//mods:mods', 'mods' => 'http://www.loc.gov/mods/v3')
  end
end
