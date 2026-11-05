# This migration comes from spotlight (originally 20261007133748)
class AddDiscoveryEnabledToSpotlightExhibits < ActiveRecord::Migration[7.1]
  def change
    add_column :spotlight_exhibits, :discovery_enabled, :boolean, default: true, null: false
  end
end
