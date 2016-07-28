class ChangeDorHarvesterResource < ActiveRecord::Migration
  def up
    Spotlight::Resource.where(type: 'Spotlight::Resources::DorHarvester').update_all(type: 'DorHarvester')
  end

  def down
    Spotlight::Resource.where(type: 'DorHarvester').update_all(type: 'Spotlight::Resources::DorHarvester')
  end
end
