# This migration comes from spotlight (originally 20151210073829)
class CreateSpotlightSite < ActiveRecord::Migration
  def change
    create_table :spotlight_sites do |t|
      t.string :title
      t.string :subtitle
      t.references :masthead
    end
  end
end
