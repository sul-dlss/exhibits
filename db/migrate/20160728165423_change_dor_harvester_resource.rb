class ChangeDorHarvesterResource < ActiveRecord::Migration[5.0]
  def up
    Spotlight::Resource.where(type: 'Spotlight::Resources::DorHarvester').update_all(type: 'DorHarvester')
  end

  def down
    Spotlight::Resource.where(type: 'DorHarvester').update_all(type: 'Spotlight::Resources::DorHarvester')
  end
end
