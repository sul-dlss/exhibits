module Spotlight::Resources
  # Base Resource indexer for objects in DOR
  class DorResource < Spotlight::Resource
    include ActiveSupport::Benchmarkable

    ##
    # Generate solr documents for the DOR resources identified by this object.
    #
    # @return [Enumerator] an enumerator of solr document hashes for indexing
    # rubocop:disable Metrics/AbcSize
    def to_solr(&block)
      return to_enum :to_solr unless block_given?

      # We use the Parallel gem to support parallel processing of the collection,
      # but need to jump through some hoops to make it yield an enumerable in the end.
      #
      # Here, we create a hook that simply yields the result to the enumerable. We configure
      # this as a 'finish' hook, which Parallel will run on the main process.
      yield_to_enum = ->(_item, _i, result) { block.call(result) }

      benchmark "Indexing resource #{inspect}" do
        base_doc = super

        Parallel.each_with_index(indexable_resources, parallel_options.merge(finish: yield_to_enum)) do |res, idx|
          benchmark "Indexing item #{res.druid} in resource #{id} (#{idx})" do
            base_doc.merge(to_solr_document(res))
          end
        end
      end
    end
    # rubocop:enable Metrics/AbcSize

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

    ##
    # Write any logs (or benchmarking information) from this class to the gdor logs
    def logger
      Spotlight::Dor::Resources.indexer.logger
    end

    def parallel_options
      Spotlight::Dor::Resources::Engine.config.parallel_options
    end
  end
end
