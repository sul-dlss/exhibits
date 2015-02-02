# This migration comes from spotlight (originally 20150127173245)
class AddFeaturedImageToExhibit < ActiveRecord::Migration
  def change
    add_column :spotlight_exhibits, :featured_image, :string
  end
end
