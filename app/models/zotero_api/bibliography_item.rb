module ZoteroApi
  ##
  # A single Zotero Bibliography item
  class BibliographyItem < HashWithIndifferentAccess
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
      "<li>#{fetch('bib')}</li>"
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
end
