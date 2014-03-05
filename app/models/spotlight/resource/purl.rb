class Spotlight::Resource
  class Purl < Spotlight::Resource
    self.weight = -1000

    def self.can_provide? res
      !!(res.url =~ /^https?:\/\/purl.stanford.edu/)
    end

    def doc_id
      url.match(/^https?:\/\/purl.stanford.edu\/([^\/\.]+)/)[1]
    end

    def to_solr
      super.merge(Spotlight::Dor::Resources.indexer.solr_document(doc_id))
    end
  end
end
