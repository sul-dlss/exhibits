# frozen_string_literal: true

# Finds and returns Purl objects for collections that a given Purl belongs to
class PurlCollections
  # @param public_xml [Nokogiri::XML::Document] the Purl public XML document
  # @return [Array<Purl>] array of Purl objects for the collections this Purl belongs to
  # @example
  #   PurlCollections.call(public_xml)
  def self.call(public_xml)
    new(public_xml).collections
  end

  # @param public_xml [Nokogiri::XML::Document] the Purl public XML document
  # @example
  #   PurlCollections.new(public_xml)
  def initialize(public_xml)
    @public_xml = public_xml
  end

  # @return [Array<Purl>] array of Purl objects for the collections this Purl belongs to
  def collections
    @collections ||= collection_druids.map { |druid| Purl.new(druid) }
  end

  private

  def collection_druids
    predicate_nodes.reject { |node| node.value.empty? }.map do |node|
      node.value.split('druid:').last
    end
  end

  def predicate_nodes
    @public_xml.xpath(member_of_collection_xpath, namespaces)
  end

  def member_of_collection_xpath
    '/publicObject/rdf:RDF/rdf:Description/pred_ns:isMemberOfCollection/@rdf:resource'
  end

  def namespaces
    { 'rdf' => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
      'pred_ns' => 'info:fedora/fedora-system:def/relations-external#' }
  end
end
