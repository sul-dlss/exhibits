# workaround for bug https://github.com/newrelic/newrelic-ruby-agent/issues/2869
class ViewComponent::Base
  def self.identifier
    source_location
  end
end
