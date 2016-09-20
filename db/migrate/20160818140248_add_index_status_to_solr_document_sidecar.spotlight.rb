# This migration comes from spotlight (originally 20160816165432)
class AddIndexStatusToSolrDocumentSidecar < ActiveRecord::Migration[5.0]
  def change
    add_column :spotlight_solr_document_sidecars, :index_status, :binary
  end
end
