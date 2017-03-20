module ZoteroApi
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
      "<ul>#{sort_by_author_date.collect(&:to_html).join}</ul>"
    end
  end
end
