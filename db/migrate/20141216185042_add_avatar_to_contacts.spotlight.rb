# This migration comes from spotlight (originally 20141126231820)
class AddAvatarToContacts < ActiveRecord::Migration
  def change
    add_column :spotlight_contacts, :avatar, :string
    add_column :spotlight_contacts, :avatar_crop_x, :integer
    add_column :spotlight_contacts, :avatar_crop_y, :integer
    add_column :spotlight_contacts, :avatar_crop_w, :integer
    add_column :spotlight_contacts, :avatar_crop_h, :integer
  end
end
