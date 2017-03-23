module ZoteroApi
  # A complete Zotero bibliography
  class Bibliography < Array
    # @return [Bibliography] all items sorted by Author-Date
    def sort_by_author_date
      self.class.new(sort_by(&:to_author_date))
    end

    def to_solr
      sort_by_author_date.collect(&:to_html)
    end
  end
end
