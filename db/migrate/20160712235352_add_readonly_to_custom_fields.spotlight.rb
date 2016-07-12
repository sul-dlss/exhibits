# This migration comes from spotlight (originally 20160329215014)
class AddReadonlyToCustomFields < ActiveRecord::Migration
  def change
    add_column :spotlight_custom_fields, :readonly_field, :boolean, default: false
  end
end
