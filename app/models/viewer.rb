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

  def mirador?
    %w(mirador mirador3).include?(viewer_type)
  end
end
