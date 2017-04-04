class SwitchToMediumText < ActiveRecord::Migration[5.0]
  def change
    change_column :spotlight_solr_document_sidecars, :data, :text, limit: 16_777_215
  end
end
