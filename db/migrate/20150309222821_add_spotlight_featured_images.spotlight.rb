# This migration comes from spotlight (originally 20150304071512)
class AddSpotlightFeaturedImages < ActiveRecord::Migration
  def change
    create_table :spotlight_featured_images do |t|
      t.string :type
      t.boolean :display
      t.string :image
      t.string :source
      t.string :document_global_id
      t.integer :image_crop_x
      t.integer :image_crop_y
      t.integer :image_crop_w
      t.integer :image_crop_h
      t.timestamps
    end
  end
end
