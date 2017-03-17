module ZoteroApi
  class Client
    attr_reader :zotero_id, :zotero_id_type

    def initialize(zotero_id, zotero_id_type = :user)
      @zotero_id = zotero_id.to_i
      @zotero_id_type = zotero_id_type == :user ? :user : :group
    end

    # @return [String] the URL for the Zotero endpoint
    def endpoint
      "https://api.zotero.org/#{zotero_id_type == :user ? 'users' : 'groups'}/#{zotero_id}"
    end

    # @return [Bibliography] the set of all bibliography items for the zotero account
    def bibliography
      return @items unless @items.nil? # cache them

      @items = Bibliography.new
      loop do
        response = conn.get 'items', include: 'data,bib',
                                     start: @items.length,
                                     limit: 100
        next_items = JSON.parse(response.body)
        break if next_items.empty?
        next_items.each do |i|
          @items << BibliographyItem.new.merge(i)
        end
      end
      @items
    end

    # @return [Hash<String,Bibliography>] an inverted index mapping druids into a bibliography
    def inverted_index
      return @index unless @index.nil?

      @index = {}
      bibliography.collect(&:druids).flatten.uniq.compact.each do |druid|
        @index[druid] = Bibliography.new
        bibliography.each do |item|
          @index[druid] << item if item.druids.include?(druid)
        end
      end
      @index
    end

    private

    # @return [Faraday::Connection] connection to the Zotero API v3 service
    def conn
      @conn ||= Faraday.new(url: endpoint, params: { v: 3, format: :json }) do |faraday|
        faraday.response :logger, ::Logger.new('log/zotero.log') # TODO: move to settings
        faraday.adapter Faraday.default_adapter
      end
    end
  end
end
