# frozen_string_literal: true

# Retrieves and represents the public xml file from PURL
class PublicXmlRecord
  attr_reader :druid, :options

  COLLECTION_TYPES = %w(collection set).freeze

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

  # @return true if the identityMetadata has <objectType>collection</objectType>, false otherwise
  def collection?
    object_type_nodes = public_xml_doc.xpath('//objectType')
    object_type_nodes.find_index { |n| COLLECTION_TYPES.include? n.text.downcase }
  end

  def items
    return [] unless collection?

    purl_fetcher_client.collection_members(druid)
  end

  def purl_base_url
    format(Settings.purl.url, druid:)
  end

  def purl_fetcher_api_endpoint
    Settings.purl_fetcher.url
  end

  def purl_fetcher_client
    @purl_fetcher_client ||= PurlFetcher::Client::Reader.new(
      nil, # TODO: Remove for purl_fetcher-client 1.0
      'purl_fetcher.api_endpoint' => purl_fetcher_api_endpoint
    )
  end
end
