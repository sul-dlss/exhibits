module ZoteroApi
  # A complete Zotero bibliography
  class Bibliography < Array
    # @return [Bibliography] all items sorted by Author-Date
    def sort_by_author_date
      self.class.new(sort_by(&:to_author_date))
    end

    # @return [String] HTML for the entire bibliography, sorted by Author-Date
    def render
      "<ul>#{sort_by_author_date.collect(&:to_html).join}</ul>"
    end
  end
end
