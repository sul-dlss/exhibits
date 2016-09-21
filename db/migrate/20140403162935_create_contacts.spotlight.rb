# This migration comes from spotlight (originally 20140218155151)
class CreateContacts < ActiveRecord::Migration[5.0]
  def change
    create_table :spotlight_contacts do |t|
      t.string :slug
      t.string :name
      t.string :email
      t.string :title
      t.string :location
      t.boolean :show_in_sidebar
      t.integer :weight, default: 50
      t.references :exhibit
      t.timestamps
    end
  end
end
