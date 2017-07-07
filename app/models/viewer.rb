##
# Model for viewer
class Viewer < ActiveRecord::Base
  belongs_to :exhibit, class_name: Spotlight::Exhibit

  def to_partial_path
    return 'oembed_default' if viewer_type == 'sul-embed' || viewer_type.nil?
    "../viewers/#{viewer_type}"
  end
end
