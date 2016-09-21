# This migration comes from spotlight (originally 20151217211019)
class CreateSpotlightExhibitFilters < ActiveRecord::Migration[5.0]
  def change
    create_table :spotlight_filters do |t|
      t.string :field
      t.string :value
      t.references :exhibit, index: true

      t.timestamps null: false
    end

    reversible do |change|
      change.up do
        Spotlight::Exhibit.all.each { |exhibit| exhibit.send(:initialize_filter) }
      end
    end
  end
end
