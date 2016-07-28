# This migration comes from spotlight (originally 20160714144125)
class AddIiifUrlToFeaturedImage < ActiveRecord::Migration
  def change
    add_column :spotlight_featured_images, :iiif_url, :string
  end
end
