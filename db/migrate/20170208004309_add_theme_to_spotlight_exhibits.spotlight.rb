# This migration comes from spotlight (originally 20170204091234)
class AddThemeToSpotlightExhibits < ActiveRecord::Migration[5.0]
  def change
    add_column :spotlight_exhibits, :theme, :string
  end
end
