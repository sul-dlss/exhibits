module Spotlight::Resources
  class DorResource < Spotlight::Resource
    def to_solr
      return to_enum :to_solr unless block_given?

      base_doc = super

      [resource, (resource.items if resource.collection?)].flatten.compact.each do |res|
        yield base_doc.merge(Spotlight::Dor::Resources.indexer.solr_document(res))
      end
    end

    def resource
      @resource ||= Spotlight::Dor::Resources.indexer.resource doc_id
    end
  end
end
