module Spotlight::Resources
  class DorResource < Spotlight::Resource

    def reindex
      run_callbacks :index do
        to_solr &method(:update_index)
      end
    end
    
    def update_index data
      blacklight_solr.update params: { commitWithin: 500 }, data: data.to_json, headers: { 'Content-Type' => 'application/json'} unless data.empty?
    end
    
    def to_solr
      return to_enum :to_solr unless block_given?
      
      base_doc = super
      
      [resource, (resource.items if resource.collection?)].flatten.compact.each do |x|
        doc = resource_to_solr(base_doc, x)
        yield doc
      end
    end
    
    def resource
      @resource ||= Spotlight::Dor::Resources.indexer.resource doc_id
    end
    
    private
    
    def resource_to_solr base_doc = {}, r
      h = Spotlight::Dor::Resources.indexer.solr_document(r)
      solr_doc = base_doc.merge(h)
      solr_doc.merge!(existing_solr_doc_hash(solr_doc))
    end
    
    def existing_solr_doc_hash doc_hash
      exhibit.blacklight_config.solr_document_model.new(doc_hash).to_solr
    end
    
    def parallel_options
      Spotlight::Dor::Resources::Engine.config.parallel_options
    end
  end
end
