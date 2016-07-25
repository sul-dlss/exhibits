module Spotlight::Resources
  # Base Resource harvester for objects in DOR
  class DorHarvester < Spotlight::Resource
    self.document_builder_class = Spotlight::Resources::DorSolrDocumentBuilder

    store :data, accessors: [:druid_list]

    class << self
      def instance(current_exhibit)
        find_or_initialize_by exhibit: current_exhibit
      end
    end

    def resources
      @resources ||= druids.map do |d|
        Spotlight::Dor::Resources.indexer.resource d
      end
    end

    def druids
      @druids ||= druid_list.split(/\s+/).reject(&:blank?)
    end

    ##
    # Enumerate the resource, and any collection members, that should be indexed
    # into this exhibit
    #
    # @return [Enumerator] an enumerator of resources to index
    def indexable_resources
      return to_enum(:indexable_resources) { resources.size + resources.sum { |r| r.items.size } } unless block_given?

      resources.each do |resource|
        yield resource

        resource.items.each do |r|
          yield r
        end
      end
    end
  end
end
