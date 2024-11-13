# frozen_string_literal: true

# This unpleasantness allows us to include the upstream controller before overriding it
spotlight_path = Gem::Specification.find_by_name('blacklight-spotlight').full_gem_path
require_dependency File.join(spotlight_path, 'app/controllers/spotlight/home_pages_controller')

module Spotlight
  # Override the upstream HomePagesController in order to inject range limit behaviors
  class HomePagesController
    # include BlacklightRangeLimit::ControllerOverride

    # rubocop:disable Rails/LexicallyScopedActionFilter
    # Tweak the authorization for the range limit actions
    before_action :authenticate_user!, except: [:show]
    # skip_authorize_resource only: %i(range_limit)

    # before_action only: %i(range_limit) do
    #   authorize! :read, @page
    # end
    # rubocop:enable Rails/LexicallyScopedActionFilter
  end
end
