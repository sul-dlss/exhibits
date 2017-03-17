module ZoteroApi
  class Client
    attr_reader :zotero_id, :zotero_id_type

    def initialize(id:, type:)
      @zotero_id = id.to_i
      @zotero_id_type = type
    end

    ##
    # @return [Hash, nil]
    def bibliography
      return @index if @index
      @index = fetch_bibliography
      @index
    end

    ##
    # @param [String] druid
    def bibliography_for(druid)
      bibliography[druid].try(:sort_by_author_date)
    end

    private

    # @return [Bibliography] the set of all bibliography items for the zotero account
    def fetch_bibliography
      index = {}
      start = 0
      loop do
        next_items = api_items(start)
        break if next_items.empty?
        next_items.each do |i|
          item = BibliographyItem.new.merge(i)
          item.druids.flatten.uniq.compact.each do |druid|
            index[druid] ||= Bibliography.new
            index[druid] << item if item.druids.include?(druid)
          end
          start += 1
        end
      end
      index
    end

    # @return [String] the URL for the Zotero endpoint
    def endpoint
      format Settings.zotero_api.endpoint, type: zotero_id_type, id: zotero_id
    end

    def response(start)
      conn.get 'items', include: 'data,bib', start: start, limit: 100
    end

    def api_items(start)
      JSON.parse(response(start).body)
    end

    # @return [Faraday::Connection] connection to the Zotero API v3 service
    def conn
      @conn ||= Faraday.new(url: endpoint, params: { v: 3, format: :json }) do |faraday|
        faraday.response :logger, ::Logger.new('log/zotero.log') # TODO: move to settings
        faraday.adapter Faraday.default_adapter
      end
    end
  end
end
