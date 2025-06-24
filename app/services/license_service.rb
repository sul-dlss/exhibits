# frozen_string_literal: true

# Translates a license URI to human-readable license text.
class LicenseService
  attr_reader :uri, :description

  # Raised when the license provided is not valid
  class LicenseServiceError < StandardError; end

  # @return [Hash] the licenses configuration loaded from config/licenses.yml
  def self.licenses
    @licenses ||= Rails.application.config_for(:licenses, env: :production)
  end

  # @param url [String] the license url
  # @return [String] the human-readable description of the license
  # @raise LicenseServiceError if the license is not valid
  def self.call(url:)
    new(url:).description
  end

  # @param url [String] the license url
  # @raise LicenseError if the license is not valid
  def initialize(url:)
    raise LicenseServiceError unless LicenseService.licenses.key?(url.to_sym)

    attrs = LicenseService.licenses.fetch(url.to_sym)
    @uri = url
    @description = attrs.fetch(:description)
  end
end
