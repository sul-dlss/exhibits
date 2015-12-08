# This migration comes from spotlight (originally 20151124101123)
class RemoveDefaultFromSpotlightExhibitAgain < ActiveRecord::Migration
  def up
    Spotlight::Exhibit.reset_column_information
    return unless Spotlight::Exhibit.column_names.include? 'default'

    remove_column :spotlight_exhibits, :default
  end
  
  def down
    add_column :spotlight_exhibits, :default, :boolean, default: true
    add_index :spotlight_exhibits, :default, unique: true
  end
end