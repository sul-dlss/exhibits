##
# A concern to be mixed into the Spotlight::Exhibit
# class in order to add ActiveRecord relationship(s)
module ExhibitExtension
  extend ActiveSupport::Concern

  included do
    has_one :bibliography_service
    has_one :viewer
  end

  def sync_bibliography
    SyncBibliographyServiceJob.perform_later(self)
  end

  ##
  # If an Exhibit doesn't already have a Viewer setup, create one.
  # @return [Viewer]
  def required_viewer
    return viewer if viewer.present?
    Viewer.create(exhibit: self)
  end
end
