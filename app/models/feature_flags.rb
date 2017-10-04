# frozen_string_literal: true

##
# A ruby class to allow for feature flags to be set given an exhibit context
# or to fall back on a base setting if no exhibit context is set.  The exhibit context can be nil, can be the
# exhibit's slug as a string or an exhibit like object (e.g. responds to #slug with a string slug)
#
# Usage:
# Each flag has been given a boolean accessor in this class so you can ask the FeatureFlags class if a feature is "on"
# FeatureFlags.for(exhibit).themes? => true
# FeatureFlags.for('test-exhibit').themes? => true
# FeatureFlags.new.themes? => false # Does not have any exhibit context so just uses base configurations
class FeatureFlags
  attr_reader :flags

  def initialize(base_settings = self.class.default_settings)
    @base_settings = base_settings
    @flags = base_settings
  end

  # Sets exhibit specific flags if configured
  def for(exhibit = nil)
    contextual_settings = base_settings.try(contextual_exhibit_slug(exhibit))
    self.flags = contextual_settings if contextual_settings.present?
    self
  end

  class << self
    delegate :for, to: :new

    def default_settings
      Settings.feature_flags
    end
  end

  private

  attr_reader :base_settings
  attr_writer :flags

  def contextual_exhibit_slug(exhibit)
    return :'' unless exhibit
    return exhibit.to_sym if exhibit.is_a?(String)
    return exhibit.slug.to_sym if exhibit.is_a?(Spotlight::Exhibit)

    raise ArgumentError, "#{exhibit.class} must be either nil, a String, or a Spotlight::Exhibit"
  end

  def respond_to_missing?(method_name, _)
    settings_includes_method_name?(method_name)
  end

  def method_missing(method_name, *args, &block)
    sanitized_method_name = method_name.to_s.gsub(/\?$/, '')

    if settings_includes_method_name?(method_name)
      if flags.respond_to?(sanitized_method_name)
        flags.send(sanitized_method_name)
      else
        base_settings.send(sanitized_method_name)
      end
    else
      super
    end
  end

  def settings_includes_method_name?(method_name)
    sanitized_method_name = method_name.to_s.gsub(/\?$/, '')

    method_name.to_s.ends_with?('?') &&
      (flags.respond_to?(sanitized_method_name) || base_settings.respond_to?(sanitized_method_name))
  end
end
