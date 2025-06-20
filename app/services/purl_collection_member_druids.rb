# frozen_string_literal: true

# Service that fetches collection member druids from PURL Fetcher
class PurlCollectionMemberDruids
  # @param druid [String] the PURL identifier (Druid)
  # @return [Array<String>] array of collection member druids
  # # @example
  #   PurlCollectionMemberDruids.call('druid:wh086yj6381') => ['druid:cj844qy2498', 'druid:bk351mv8257']
  def self.call(druid)
    new(druid).collection_member_druids
  end

  # @param druid [String] the PURL identifier (Druid)
  # @example
  #   PurlCollectionMemberDruids.new('druid:wh086yj6381')
  def initialize(druid)
    @druid = druid
  end

  # @return [Array<String>] array of collection member druids
  def collection_member_druids
    @collection_member_druids ||= purl_fetcher_client.collection_members(@druid).pluck('druid')
  end

  private

  def purl_fetcher_client
    PurlFetcher::Client::Reader.new(host: Settings.purl_fetcher.url)
  end
end
