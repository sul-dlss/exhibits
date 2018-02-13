# This migration comes from spotlight (originally 20180119193632)
class AddSearchBoxToSpotlightSearches < ActiveRecord::Migration[5.0]
  def change
    add_column :spotlight_searches, :search_box, :boolean, default: false
  end
end
