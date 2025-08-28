# frozen_string_literal: true

# This unpleasantness allows us to include the upstream controller before overriding it
spotlight_path = Gem::Specification.find_by_name('blacklight-spotlight').full_gem_path
require_dependency File.join(spotlight_path, 'app/controllers/spotlight/about_pages_controller')

# Override the upstream controller to add turnstile
module Spotlight
  ##
  # Controller for about pages
  class AboutPagesController
    bot_challenge only: :show
  end
end
