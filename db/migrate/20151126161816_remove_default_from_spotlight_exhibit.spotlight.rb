# This migration comes from spotlight (originally 20151124101123)
class RemoveDefaultFromSpotlightExhibit < ActiveRecord::Migration[5.0]
  def up
    return unless Spotlight::Exhibit.column_names.include? 'default'

    remove_column :spotlight_exhibits, :default
  end
  
  def down
    add_column :spotlight_exhibits, :default, :boolean, unique: true
    add_index :spotlight_exhibits, :default, unique: true
  end
end