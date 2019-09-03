# This migration comes from spotlight (originally 20190813085432)
class AddIsMultipleToCustomFields < ActiveRecord::Migration[5.1]
  def change
    change_table :spotlight_custom_fields do |t|
      t.boolean :is_multiple, default: false
    end
  end
end
