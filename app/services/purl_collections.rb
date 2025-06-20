# frozen_string_literal: true

# Finds and returns Purl objects for collections that a given Purl belongs to
class PurlCollections
  # @param public_cocina [Hash] the Purl public cocina hash
  # @return [Array<Purl>] array of Purl objects for the collections this Purl belongs to
  # @example
  #   PurlCollections.call(public_cocina)
  def self.call(public_cocina)
    new(public_cocina).collections
  end

  # @param public_cocina [Hash] the Purl public cocina hash
  # @example
  #   PurlCollections.new(public_cocina)
  def initialize(public_cocina)
    @public_cocina = public_cocina
  end

  # @return [Array<Purl>] array of Purl objects for the collections this Purl belongs to
  def collections
    @collections ||= collection_druids.map { |druid| Purl.new(druid) }
  end

  private

  def collection_druids
    Array(@public_cocina.dig('structural', 'isMemberOf')).map do |druid|
      druid.delete_prefix('druid:')
    end
  end
end
