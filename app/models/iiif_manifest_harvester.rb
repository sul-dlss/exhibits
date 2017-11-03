# frozen_string_literal: true

require 'iiif/presentation'

##
# Responsible for grabbing a IIIF manifest and parsing it
class IiifManifestHarvester
  attr_reader :url

  def initialize(url)
    @url = url
  end

  def canvases
    # TODO: Support multiple sequences
    manifest.sequences.first.canvases
  end

  def manifest
    @manifest ||= begin
      IIIF::Service.parse(Faraday.get(url).body)
    end
  end
end
