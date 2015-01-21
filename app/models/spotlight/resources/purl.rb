module Spotlight::Resources
  class Purl < Spotlight::Resource
    self.weight = -1000

    def self.can_provide? res
      !!(res.url =~ /^https?:\/\/purl.stanford.edu/)
    end

    def doc_id
      url.match(/^https?:\/\/purl.stanford.edu\/([^#\/\.]+)/)[1]
    end

    def to_solr
      base_doc = super
      if resource.collection?
        [resource, resource.items].flatten.map do |x|
          base_doc.merge Spotlight::Dor::Resources.indexer.solr_document(x)
        end
      else
        base_doc.merge Spotlight::Dor::Resources.indexer.solr_document(resource)
      end
    end

    def resource
      @resource ||= Spotlight::Dor::Resources.indexer.resource doc_id
    end
  end
end
