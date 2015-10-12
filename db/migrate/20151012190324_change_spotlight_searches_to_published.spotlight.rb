# This migration comes from spotlight (originally 20150713160101)
class ChangeSpotlightSearchesToPublished < ActiveRecord::Migration
  def up
    rename_column :spotlight_searches, :on_landing_page, :published
  end
end
