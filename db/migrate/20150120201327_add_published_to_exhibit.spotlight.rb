# This migration comes from spotlight (originally 20150116161616)
class AddPublishedToExhibit < ActiveRecord::Migration[5.0]
  def change
    add_column :spotlight_exhibits, :published, :boolean, default: true
    add_column :spotlight_exhibits, :published_at, :datetime

    reversible do |dir|
      dir.up do
        Spotlight::Exhibit.find_each do |e|
          e.published = true
          e.save!
        end
      end
    end
  end
end
