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

  def to_partial_path
    return 'oembed_default' if viewer_type == 'sul-embed' || viewer_type.nil?
    "../viewers/#{viewer_type}"
  end
end
