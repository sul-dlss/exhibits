# This migration comes from spotlight (originally 20150224071743)
class AddSpotlightMastheads < ActiveRecord::Migration[5.0]
  def change
    create_table :spotlight_mastheads do |t|
      t.boolean :display
      t.string :image
      t.string :source
      t.string :document_global_id
      t.integer :image_crop_x
      t.integer :image_crop_y
      t.integer :image_crop_w
      t.integer :image_crop_h
      t.references :exhibit
      t.timestamps
    end
  end
end
