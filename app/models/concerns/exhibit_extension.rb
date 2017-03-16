##
# A concern to be mixed into the Spotlight::Exhibit
# class in order to add ActiveRecord relationship(s)
module ExhibitExtension
  extend ActiveSupport::Concern

  included do
    has_one :bibliography_service
  end
end
