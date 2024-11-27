# frozen_string_literal: true

module BlacklightRangeLimit
  # Overriding the BlacklightRangeLimit::Routes::RangeSearchable class to
  # remove the deprecated 'range_limit_panel/:id' route.
  module Routes
    # Subclass of BlacklightRangeLimit::Routes::RangeSearchable that removes the deprecated 'range_limit_panel/:id'
    # route. Bots keep hitting this route, creating a lot of noise in honeybadger.
    # This file should be removed once blacklight_range_limit removes the route.
    class ExhibitsRangeSearchable < BlacklightRangeLimit::Routes::RangeSearchable
      def call(mapper, _options = {})
        mapper.get 'range_limit', action: 'range_limit'
      end
    end
  end
end
