# The bibliography service configurations for an exhibit
class BibliographyService < ActiveRecord::Base
  belongs_to :exhibit, class_name: Spotlight::Exhibit
  delegate :sync_bibliography, to: :exhibit

  def header
    super || I18n.t('services.bibliography_service.default_header')
  end

  def initial_sync_complete?
    sync_completed_at.present?
  end

  def api_settings_changed?
    api_id_previously_changed? || api_type_previously_changed?
  end

  def mark_as_updated!
    update(sync_completed_at: DateTime.current)
  end

  def update_and_sync_bibliography(update_params)
    updated = update(update_params)
    return unless updated
    sync_bibliography if api_settings_changed?
    updated
  end
end
