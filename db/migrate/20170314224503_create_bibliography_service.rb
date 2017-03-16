class CreateBibliographyService < ActiveRecord::Migration[5.0]
  def change
    create_table :bibliography_services do |t|
      t.string     :header
      t.string     :api_id
      t.string     :api_type
      t.datetime   :sync_completed_at
      t.references :exhibit
      t.timestamps
    end
  end
end
