# This migration comes from spotlight (originally 20160711121314)
class AddDefaultViewToSpotlightSearches < ActiveRecord::Migration[5.0]
  def change
    add_column :spotlight_searches, :default_index_view_type, :string
  end
end
