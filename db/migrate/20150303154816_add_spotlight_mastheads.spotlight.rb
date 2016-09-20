# This migration comes from spotlight (originally 20150224071743)
class AddSpotlightMastheads < ActiveRecord::Migration[5.0]
  def change
    create_table :spotlight_mastheads do |t|
      t.boolean :display
      t.string :image
      t.string :source
      t.string :document_global_id
      t.integer :image_crop_x, :integer
      t.integer :image_crop_y, :integer
      t.integer :image_crop_w, :integer
      t.integer :image_crop_h, :integer
      t.references :exhibit
      t.timestamps
    end
  end
end
