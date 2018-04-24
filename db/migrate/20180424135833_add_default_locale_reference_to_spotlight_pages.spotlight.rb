# This migration comes from spotlight (originally 20180406212516)
class AddDefaultLocaleReferenceToSpotlightPages < ActiveRecord::Migration[5.0]
  def change
    change_table :spotlight_pages do |t|
      t.references :default_locale_page
    end
  end
end
