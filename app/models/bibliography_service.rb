# The bibliography service configurations for an exhibit
class BibliographyService < ActiveRecord::Base
  belongs_to :exhibit

  def header
    super || I18n.t('services.bibliography_service.default_header')
  end

  def initial_sync_complete?
    sync_completed_at.present?
  end
end
