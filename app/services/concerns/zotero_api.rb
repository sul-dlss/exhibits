#
# @see https://www.zotero.org/support/dev/web_api/v3/start
#
module ZoteroApi
  # A single Zotero Bibliography item
  class BibliographyItem < Hash
    # @return [String] an Author-Date sort key
    def to_author_date
      [author, date].join(' ')
    end

    # @return [String] returns the first author's full name (last, first)
    def author
      creator = data['creators'].first
      [creator['lastName'], creator['firstName']].join(', ')
    end

    # @return [String] the (unparsed) date for the item
    def date
      data['date']
    end

    # @return [Array<String>] all of the tags associated with the item
    def tags
      data['tags'].collect { |i| i['tag'] }
    end

    # @return [String] the HTML that represents the bibliography entry for the item
    # @example
    #     <div class="csl-bib-body" style="line-height: 1.35; padding-left: 2em; text-indent:-2em;">
    #       <div class="csl-entry">Allen, John. <i>Another Book</i>, 2017.</div>
    #     </div>
    #
    def to_html
      fetch('bib')
    end

    # @return [Array<String>] the list of druids associated with this bibliography item
    def druids
      druids = []
      tags.each do |t|
        druid = t.match(/([a-z]{2}[0-9]{3}[a-z]{2}[0-9]{4})/) # parse out druid from tag
        druids << druid[1] unless druid.nil?
      end
      druids.uniq
    end

    private

    def data
      fetch('data')
    end
  end

  # A complete Zotero bibliography
  class Bibliography < Array
    # @return [Bibliography] all items sorted by Author-Date
    def sort_by_author_date
      self.class.new(sort_by(&:to_author_date))
    end

    # @param [String] `key` the bibliography item's `key` value
    # @return [BibliographyItem] the matching item, or `nil`
    def find(key)
      each { |item| return item if item['key'] == key }
      nil
    end

    # @return [String] HTML for the entire bibliography, sorted by Author-Date
    def render
      sort_by_author_date.collect(&:to_html).join("\n")
    end
  end

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
