# This migration comes from spotlight (originally 20151016092343)
class RemoveSearchableFromExhibit < ActiveRecord::Migration
  def up
    Spotlight::Exhibit.where(searchable: false).find_each do |e|
      e.home_page.update(display_sidebar: false)
    end

    remove_column :spotlight_exhibits, :searchable
  end

  def down
    add_column :spotlight_exhibits, :searchable, :boolean, default: true
  end
end
