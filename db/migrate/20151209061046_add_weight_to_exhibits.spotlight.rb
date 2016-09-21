# This migration comes from spotlight (originally 20151208085432)
class AddWeightToExhibits < ActiveRecord::Migration[5.0]
  def up
    add_column :spotlight_exhibits, :weight, :integer, default: 50
  end
end
