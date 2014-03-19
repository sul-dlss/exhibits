module Spotlight::Resources
  class Searchworks < Spotlight::Resource

    self.weight = -1000

    def self.can_provide? res
      !!(res.url =~ /^https?:\/\/searchworks[^\.]+.stanford.edu/)
    end

    def doc_id
      url.match(/^https?:\/\/searchworks[^\.]+.stanford.edu\/.*view\/([^\/]+)/)[1]
    end

    def to_solr
      super.merge((Spotlight::Dor::Resources.indexer.solr_document(doc_id) rescue Hash.new))
    end
  end
end
