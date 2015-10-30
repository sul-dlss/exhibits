module Spotlight::Resources
  class DorResource < Spotlight::Resource
    ##
    # Generate solr documents for the DOR resources identified by this object
    #
    # @return [Enumerator] an enumerator of solr document hashes for indexing
    def to_solr
      return to_enum :to_solr unless block_given?

      base_doc = super

      indexable_resources.each do |res|
        yield base_doc.merge(to_solr_document(res))
      end
    end

    def resource
      @resource ||= Spotlight::Dor::Resources.indexer.resource doc_id
    end

    private

    ##
    # Enumerate the resource, and any collection members, that should be indexed
    # into this exhibit
    #
    # @return [Enumerator] an enumerator of resources to index
    def indexable_resources
      return to_enum(:indexable_resources) unless block_given?

      yield resource

      resource.items.each do |r|
        yield r
      end
    end

    ##
    # Generate the solr document hash for a given resource by applying the current
    # indexer steps.
    #
    # @return [Hash]
    def to_solr_document(resource)
      Spotlight::Dor::Resources.indexer.solr_document(resource)
    end
  end
end
