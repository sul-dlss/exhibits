##
# A revesible data migration to switch the spotlight_upload prefixed
# field data with the previously generically named title/date data
class MigrateSpotlightUploadFieldConfig < ActiveRecord::Migration[5.1]
  NEW_TITLE_FIELD = 'spotlight_upload_title_tesim'.freeze
  OLD_TITLE_FIELD = 'title'.freeze
  NEW_DATE_FIELD = 'spotlight_upload_title_tesim'.freeze
  OLD_DATE_FIELD = 'date'.freeze

  def up
    Spotlight::Resources::Upload.find_each do |upload|
      next unless upload.exhibit
      next unless upload.sidecar
      sidecar = upload.sidecar

      upload.data = migrate_data_up(upload.data)
      sidecar.data['configured_fields'] = migrate_data_up(sidecar.data['configured_fields'])

      sidecar.save
      upload.save_and_index
    end
  end

  def down
    Spotlight::Resources::Upload.find_each do |upload|
      next unless upload.exhibit
      next unless upload.sidecar
      sidecar = upload.sidecar

      upload.data = migrate_data_down(upload.data)
      sidecar.data['configured_fields'] = migrate_data_down(sidecar.data['configured_fields'])

      sidecar.save
      upload.save_and_index
    end
  end

  def migrate_data_up(data)
    if data[OLD_TITLE_FIELD].present?
      data[NEW_TITLE_FIELD] = data[OLD_TITLE_FIELD]
      data.delete(OLD_TITLE_FIELD)
    end

    if data[OLD_DATE_FIELD].present?
      data[NEW_DATE_FIELD] = data[OLD_DATE_FIELD]
      data.delete(OLD_DATE_FIELD)
    end

    data
  end

  def migrate_data_down(data)
    if data[NEW_TITLE_FIELD].present?
      data[OLD_TITLE_FIELD] = data[NEW_TITLE_FIELD]
      data.delete(NEW_TITLE_FIELD)
    end

    if data[NEW_DATE_FIELD].present?
      data[OLD_DATE_FIELD] = data[NEW_DATE_FIELD]
      data.delete(OLD_DATE_FIELD)
    end

    data
  end
end
