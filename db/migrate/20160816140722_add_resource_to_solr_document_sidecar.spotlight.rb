# This migration comes from spotlight (originally 20160815165432)
class AddResourceToSolrDocumentSidecar < ActiveRecord::Migration
  def change
    add_column :spotlight_solr_document_sidecars, :resource_id, :integer
    add_column :spotlight_solr_document_sidecars, :resource_type, :string
    
    add_index :spotlight_solr_document_sidecars, [:resource_type, :resource_id], name: 'spotlight_solr_document_sidecars_resource'
  end
end
