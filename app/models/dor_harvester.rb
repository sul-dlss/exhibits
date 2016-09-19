# Base Resource harvester for objects in DOR
class DorHarvester < Spotlight::Resource
  self.document_builder_class = DorSolrDocumentBuilder

  store :data, accessors: [:druid_list, :collections]

  class << self
    def instance(current_exhibit)
      find_or_initialize_by exhibit: current_exhibit
    end
  end

  def resources
    @resources ||= druids.map { |d| Spotlight::Dor::Resources.indexer.resource(d) }
  end

  def druids
    @druids ||= druid_list.split(/\s+/).reject(&:blank?).uniq
  end

  def waiting!
    super
    update(collections: fetch_collection_metadata)
  end

  def collections
    data[:collections] ||= {}
    super
  end

  ##
  # Enumerate the resource, and any collection members, that should be indexed
  # into this exhibit
  #
  # @return [Enumerator] an enumerator of resources to index
  def indexable_resources
    return to_enum(:indexable_resources) { size } unless block_given?

    resources.each do |resource|
      unless resource.exists?
        on_error(resource, 'Missing')
        next
      end

      yield resource

      resource.items.each do |r|
        yield r
      end
    end
  end

  def on_success(resource)
    sidecar(resource.bare_druid).update(index_status: { ok: true, timestamp: Time.zone.now })
  end

  def on_error(resource, exception_or_message)
    message = if exception_or_message.is_a? Exception
                exception_or_message.inspect
              else
                exception_or_message.to_s
              end

    sidecar(resource.bare_druid).update(index_status: { ok: false, message: message, timestamp: Time.zone.now })
  end

  private

  def size
    @size ||= resources.select(&:exists?).sum { |r| r.items.size }
  end

  def fetch_collection_metadata
    resources.select(&:exists?).select(&:collection?).each_with_object({}) do |obj, memo|
      memo[obj.bare_druid] = { size: obj.items.size }
    end
  end

  def sidecar(id)
    exhibit.solr_document_sidecars.find_or_initialize_by(document_id: id, document_type: document_model) do |sidecar|
      sidecar.resource = self
    end
  end
end
