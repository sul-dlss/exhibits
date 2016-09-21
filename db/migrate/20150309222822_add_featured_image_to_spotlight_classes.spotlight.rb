# This migration comes from spotlight (originally 20150304111111)
class AddFeaturedImageToSpotlightClasses < ActiveRecord::Migration[5.0]
  def change
    add_column :spotlight_searches, :masthead_id, :integer
    add_column :spotlight_searches, :thumbnail_id, :integer
    add_column :spotlight_exhibits, :masthead_id, :integer
    add_column :spotlight_exhibits, :thumbnail_id, :integer
    add_column :spotlight_pages, :thumbnail_id, :integer
  end
end
