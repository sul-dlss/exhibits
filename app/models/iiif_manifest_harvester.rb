# frozen_string_literal: true

require 'iiif/presentation'

##
# Responsible for grabbing a IIIF manifest and parsing it
class IiifManifestHarvester
  RANGE_TYPE = 'sc:Range'.freeze

  attr_reader :url

  def initialize(url)
    @url = url
  end

  def canvases
    # TODO: Support multiple sequences
    manifest.sequences.first.canvases
  end

  def ranges_for(canvas_id)
    ranges.select do |range|
      normalized_canvases = range.canvases.map { |c| c.partition('#').first }
      normalized_canvases.include?(canvas_id)
    end
  end

  def manifest
    @manifest ||= begin
      IIIF::Service.parse(Faraday.get(url).body)
    end
  end

  private

  def ranges
    return [] if manifest.structures.blank?

    @ranges ||= manifest.structures.select do |structure|
      structure['@type'] == RANGE_TYPE
    end
  end
end
