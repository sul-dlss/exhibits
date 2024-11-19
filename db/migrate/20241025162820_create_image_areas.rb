class CreateImageAreas < ActiveRecord::Migration[7.2]
  def change
    create_table :image_areas do |t|
      t.text :workspace_state

      t.timestamps
    end
  end
end
