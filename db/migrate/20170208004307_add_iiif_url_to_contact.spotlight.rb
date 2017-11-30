# This migration comes from spotlight (originally 20160718194010)
class AddIiifUrlToContact < ActiveRecord::Migration[5.0]
  def change
    add_column :spotlight_contacts, :avatar_id, :integer
    add_index :spotlight_contacts, :avatar_id
  end
end
