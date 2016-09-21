# This migration comes from spotlight (originally 20151210073829)
class CreateSpotlightSite < ActiveRecord::Migration[5.0]
  def change
    create_table :spotlight_sites do |t|
      t.string :title
      t.string :subtitle
      t.references :masthead
    end
  end
end
