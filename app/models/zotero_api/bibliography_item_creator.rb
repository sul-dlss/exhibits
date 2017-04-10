module ZoteroApi
  ##
  # A single Bibliography Item Creator
  class BibliographyItemCreator
    attr_reader :metadata

    ##
    # @param [Hash] A "Creator" from the ZoteroApi response
    def initialize(metadata)
      @metadata = metadata || {}
    end

    def first_name
      metadata.fetch('firstName', nil)
    end

    def last_name
      metadata.fetch('lastName', nil)
    end

    def formatted_author
      if first_name || last_name
        [last_name, first_name].compact.join(', ')
      else
        ''
      end
    end
  end
end
