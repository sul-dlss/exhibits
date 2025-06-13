# frozen_string_literal: true

# Represents a collection Purl objects
class PurlCollection
  COLLECTION_TYPES = %w(collection set).freeze

  def initialize(public_xml)
    @public_xml = public_xml
  end

  # @return true if the identityMetadata has <objectType>collection</objectType>, false otherwise
  def collection?
    object_type_nodes = @public_xml.xpath('//objectType')
    object_type_nodes.find_index { |n| COLLECTION_TYPES.include? n.text.downcase }
  end

  def collections
    @collections ||= collection_druids.map { |druid| Purl.new(druid) }
  end

  def items
    return [] unless collection?

    purl_fetcher_client.collection_members(druid)
  end

  private

  # get the druids from predicate relationships in rels-ext from public_xml
  # @return [Array<String>, nil] the druids (e.g. ww123yy1234) from the rdf:resource of the predicate relationships,
  #                              or nil if none
  def collection_druids
    ns_hash = { 'rdf' => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
                'pred_ns' => 'info:fedora/fedora-system:def/relations-external#' }
    xpath = '/publicObject/rdf:RDF/rdf:Description/pred_ns:isMemberOfCollection/@rdf:resource'
    pred_nodes = @public_xml.xpath(xpath, ns_hash)
    pred_nodes.reject { |n| n.value.empty? }.map do |n|
      n.value.split('druid:').last
    end
  end

  def purl_fetcher_api_endpoint
    Settings.purl_fetcher.url
  end

  def purl_fetcher_client
    @purl_fetcher_client ||= PurlFetcher::Client::Reader.new(host: purl_fetcher_api_endpoint)
  end
end
