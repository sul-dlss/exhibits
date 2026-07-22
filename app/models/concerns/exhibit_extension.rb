# frozen_string_literal: true

##
# A concern to be mixed into the Spotlight::Exhibit
# class in order to add application specific behavior
module ExhibitExtension
  extend ActiveSupport::Concern

  class_methods do
    # Slugs of retired exhibits that now 301-rdirect (see
    # Settings.retired_exhibit_slugs and config/routes.rb). They must never be
    # reassigned to a new exhibit, or the redirect would shadow it and
    # make the new exhibit unreachable.
    def retired_slugs
      Settings.retired_exhibit_slugs.to_h.keys.map(&:to_s)
    end
  end

  included do
    # Reserve retired slugs so the admin slug form rejects them ("is reserved"),
    # the same mechanism Spotlight uses to reserve "site".
    friendly_id_config.reserved_words.concat(retired_slugs - friendly_id_config.reserved_words)

    has_one :viewer, dependent: :delete

    after_update :send_publish_state_change_notification
    after_save :index_exhibit_metadata

    scope :discoverable, -> { where.not(slug: Settings.nondiscoverable_exhibit_slugs) }
  end

  ##
  # If an Exhibit doesn't already have a Viewer setup, create one.
  # @return [Viewer]
  def required_viewer
    return viewer if viewer.present?

    Viewer.create(exhibit: self)
  end

  private

  def send_publish_state_change_notification
    return unless saved_changes.key?('published')

    SendPublishStateChangeNotificationJob.perform_later(exhibit: self, published: published)
  end

  def index_exhibit_metadata
    if published?
      IndexExhibitMetadataJob.perform_later(exhibit: self, action: 'add')
    elsif saved_change_to_published?
      IndexExhibitMetadataJob.perform_later(exhibit: self, action: 'delete')
    end
  end
end
