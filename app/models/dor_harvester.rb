# frozen_string_literal: true

# Base Resource harvester for objects in DOR
class DorHarvester < Spotlight::Resource
  self.document_builder_class = DorSolrDocumentBuilder

  store :data, accessors: [:druid_list, :collections]

  before_index :trigger_update_resource_metadata

  class << self
    def instance(current_exhibit)
      find_or_initialize_by exhibit: current_exhibit
    end
  end

  def resources
    return to_enum(:resources) { druids.size } unless block_given?

    druids.each { |d| yield harvestdor_resource(d) }
  end

  def druids
    @druids ||= druid_list.split(/\s+/).reject(&:blank?).uniq
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
    RecordIndexStatusJob.perform_later(self, resource.bare_druid, ok: true)
    IndexRelatedContentJob.perform_later(self, resource.bare_druid) if index_related_content?
  end

  def index_related_content?
    FeatureFlags.for(exhibit.slug).index_related_content?
  end

  def on_error(resource, exception_or_message)
    message = if exception_or_message.is_a? Exception
                exception_or_message.inspect
              else
                exception_or_message.to_s
              end.truncate(1.megabyte)
    RecordIndexStatusJob.perform_later(self, resource.bare_druid, ok: false, message: message)
  end

  def trigger_update_resource_metadata
    update(collections: {})
    RecordResourceMetadataJob.perform_later(self)
  end

  def update_collection_metadata!
    update(collections: fetch_collection_metadata)
  end

  private

  def size
    @size ||= resources.select(&:exists?).sum { |r| r.collection? ? r.items.size : 1 }
  end

  def fetch_collection_metadata
    resources.select(&:exists?).select(&:collection?).each_with_object({}) do |obj, memo|
      memo[obj.bare_druid] = { size: obj.items.size }
    end
  end

  def harvestdor_resource(druid)
    Harvestdor::Indexer::Resource.new(harvestdor_indexer, druid)
  end

  def harvestdor_indexer
    @harvestdor_indexer ||= Harvestdor::Indexer.new(
      purl_fetcher: Settings.purl_fetcher.to_h,
      harvestdor: Settings.harvestdor
    )
  end
end
