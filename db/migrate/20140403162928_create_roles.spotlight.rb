# This migration comes from spotlight (originally 20140128155152)
class CreateRoles < ActiveRecord::Migration[5.0]
  def change
    create_table :spotlight_roles do |t|
      t.references :exhibit
      t.references :user
      t.string :role
    end

    add_index :spotlight_roles, [:exhibit_id, :user_id], unique: true
  end
end
