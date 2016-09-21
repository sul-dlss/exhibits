# This migration comes from spotlight (originally 20150306202300)
class AddDisplayToSpotlightMainNavigations < ActiveRecord::Migration[5.0]
  def up
    add_column :spotlight_main_navigations, :display, :boolean, default: true

    Spotlight::MainNavigation.reset_column_information
    Spotlight::MainNavigation.update_all display: true
  end

  def down
    remove_column :spotlight_main_navigations, :display
  end
end
