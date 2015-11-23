# This migration comes from spotlight (originally 20151117153210)
class ChangeSpotlightExhibitPublishedDefault < ActiveRecord::Migration
  def up
    change_column :spotlight_exhibits, :published, :boolean, default: false
  end
end