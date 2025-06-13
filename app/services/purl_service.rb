# frozen_string_literal: true

# Retrieves data from PURL in the specified format (XML, JSON, MODS)
class PurlService
  attr_reader :druid

  # @param druid [String] the PURL identifier (Druid) without the 'druid:' prefix
  # @param format [Symbol] the format of the response, defaults to :xml
  # @example
  #   PurlService.new('cd028hy1429', format: :json)
  def initialize(druid, format: :xml)
    @druid = druid
    @format = format
  end

  # @return [Boolean] true if the PURL exists, false otherwise
  def exists?
    response_body.present?
  rescue Faraday::Error
    false
  end

  # @return [String, nil] the body of the response if successful, otherwise nil
  def response_body
    @response_body ||= get.body if get.success?
  end

  private

  def get
    @get ||= Faraday.get("#{purl_base_url}.#{@format}")
  end

  def purl_base_url
    format(Settings.purl.url, druid:)
  end
end
