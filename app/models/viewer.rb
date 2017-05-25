##
# Model for viewer
class Viewer < ActiveRecord::Base
  belongs_to :exhibit, class_name: Spotlight::Exhibit
end
