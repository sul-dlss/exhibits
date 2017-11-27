# This migration comes from spotlight (originally 20160805143841)
class AddUploadIdToResources < ActiveRecord::Migration[5.0]
  def change
    add_column :spotlight_resources, :upload_id, :integer
    add_index :spotlight_resources, :upload_id
  end
end
