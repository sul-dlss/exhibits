# Base Resource indexer for objects in DOR
class DorSolrDocumentBuilder < Spotlight::SolrDocumentBuilder
  include ActiveSupport::Benchmarkable

  delegate :indexable_resources, to: :resource

  ##
  # Generate solr documents for the DOR resources identified by this object
  #
  # @return [Enumerator] an enumerator of solr document hashes for indexing
  def to_solr
    return to_enum(:to_solr) { size } unless block_given?

    benchmark "Indexing resource #{inspect} (est. #{size} items)" do
      base_doc = super

      indexable_resources.each_with_index do |res, idx|
        process_resource_with_logging(res, idx) do
          doc = to_solr_document(res)
          yield base_doc.merge(doc) if doc
        end
      end
    end
  end

  private

  def resource_id
    resource.id
  end

  def process_resource_with_logging(res, idx)
    benchmark "Indexing item #{res.druid} in resource #{resource_id} (#{idx} / #{size})" do
      yield
    end
    resource.on_success(res)
  rescue => e
    logger.error("Error processing #{res.druid}: #{e}")
    resource.on_error(res, e)
    Honeybadger.notify(e, context: { druid: res.druid, resource_id: resource_id })
  ensure
    resource.save if resource.persisted?
  end

  ##
  # Estimate the number of documents this resource will create
  def size
    indexable_resources.size
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
end
