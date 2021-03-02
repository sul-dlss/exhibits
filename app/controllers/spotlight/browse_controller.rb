# frozen_string_literal: true

# This unpleasantness allows us to include the upstream controller before overriding it
spotlight_path = Gem::Specification.find_by_name('blacklight-spotlight').full_gem_path
require_dependency File.join(spotlight_path, 'app/controllers/spotlight/browse_controller')

module Spotlight
  # Override the upstream controller to disable bulk actions.
  class BrowseController
    def render_bulk_actions?
      false
    end
  end
end
