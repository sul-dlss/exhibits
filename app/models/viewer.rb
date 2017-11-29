# frozen_string_literal: true

##
# Model for viewer
class Viewer < ApplicationRecord
  belongs_to :exhibit, class_name: 'Spotlight::Exhibit'
  validates :custom_manifest_pattern,
            format: {
              with: /{id}/
            },
            allow_blank: true,
            allow_nil: true

  def default_viewer_path
    'oembed_default'
  end

  def to_partial_path
    return default_viewer_path if viewer_type == 'sul-embed' || viewer_type.nil?
    "../viewers/#{viewer_type}"
  end
end
