# This migration comes from spotlight (originally 20140211203403)
class CreateSpotlightCustomFields < ActiveRecord::Migration[5.0]
  def change
    create_table :spotlight_custom_fields do |t|
      t.references :exhibit
      t.string :slug
      t.string :field
      t.text :configuration

      t.timestamps
    end
  end
end
