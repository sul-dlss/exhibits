##
# A revesible data migration to switch the spotlight_upload prefixed
# field data with the previously generically named title/date data
class MigrateSpotlightUploadFieldConfig < ActiveRecord::Migration[5.1]
  def up
    Spotlight::Resources::Upload.find_each do |upload|
      data = upload.data
      upload.data = data.merge(
        'spotlight_upload_title_tesim' => data['title'],
        'spotlight_upload_date_tesim' => data['date']
      ).delete_if { |k, _| %w[date title].include?(k) }

      upload.save_and_index
    end
  end

  def down
    Spotlight::Resources::Upload.find_each do |upload|
      data = upload.data
      upload.data = data.merge(
        'title' => data['spotlight_upload_title_tesim'],
        'date' => data['spotlight_upload_date_tesim']
      ).delete_if { |k, _| %w[spotlight_upload_date_tesim spotlight_upload_title_tesim].include?(k) }

      upload.save_and_index
    end
  end
end
