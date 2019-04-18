# frozen_string_literal: true

# This makes routes in rspec behave like routes in
# the application as run.
module OptionalLocaleRouteParamInjection
  def url_options
    default_url_options.merge(locale: nil)
  end
end
