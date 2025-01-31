# frozen_string_literal: true

##
# Model for viewer
class Viewer < ApplicationRecord
  belongs_to :exhibit, class_name: 'Spotlight::Exhibit'
  validates :custom_manifest_pattern,
            format: {
              with: /{id}/
            },
            allow_blank: true

  def default_viewer_path
    'catalog/oembed_default'
  end

  def to_partial_path
    return default_viewer_path if viewer_type == 'sul-embed' || viewer_type.nil?

    modified_viewer_type = viewer_type == 'mirador' ? 'mirador3' : viewer_type

    "/viewers/#{modified_viewer_type}"
  end
end
