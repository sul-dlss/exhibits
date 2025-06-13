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

  # @return objectLabel value from the DOR identity_metadata, or nil if there is no barcode
  def label
    public_xml_doc.xpath('/publicObject/identityMetadata/objectLabel').first&.content
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

  # the value of the type attribute for a DOR object's contentMetadata
  #  more info about these values is here:
  #    https://consul.stanford.edu/display/chimera/DOR+content+types%2C+resource+types+and+interpretive+metadata
  #    https://consul.stanford.edu/display/chimera/Summary+of+Content+Types%2C+Resource+Types+and+their+behaviors
  # @return [String]
  def dor_content_type
    public_xml_doc.xpath('//contentMetadata/@type').text
  end

  def collections
    @collections ||= predicate_druids('isMemberOfCollection').map do |druid|
      PublicXmlRecord.new(druid, options)
    end
  end

  def items
    return [] unless collection?

    purl_fetcher_client.collection_members(druid)
  end

  # get the druids from predicate relationships in rels-ext from public_xml
  # @return [Array<String>, nil] the druids (e.g. ww123yy1234) from the rdf:resource of the predicate relationships,
  #                              or nil if none
  def predicate_druids(predicate, predicate_ns = 'info:fedora/fedora-system:def/relations-external#')
    ns_hash = { 'rdf' => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#', 'pred_ns' => predicate_ns }
    xpth = "/publicObject/rdf:RDF/rdf:Description/pred_ns:#{predicate}/@rdf:resource"
    pred_nodes = public_xml_doc.xpath(xpth, ns_hash)
    pred_nodes.reject { |n| n.value.empty? }.map do |n|
      n.value.split('druid:').last
    end
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
