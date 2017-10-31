require 'iiif/presentation'

class IiifManifestHarvester
  attr_reader :url

  def initialize(url, id)
    @url = url
    @id = id
  end

  def canvases
    # TODO: Support multiple sequences
    manifest.sequences.first.canvases
  end

  def manifest
    @manifest ||= begin
      conn = Faraday.new(url: url)
      response = conn.get
      IIIF::Service.parse(response.body)
    end
  end
end
