# frozen_string_literal: true

# Render the Cocina metadata component
module CocinaMetadata
  # Renders the access section for Cocina metadata display
  class AccessComponent < ViewComponent::Base
    def initialize(document:)
      @document = document
      super()
    end

    def call
      render MetadataComponent.new(field_labels_with_values:)
    end

    def metadata?
      use_and_reproduction_statement.present? || license_statement.present?
    end

    private

    def field_labels_with_values
      use_and_reproduction_statement_hash.merge(license_statement_hash)
    end

    def use_and_reproduction_statement_hash
      return {} unless use_and_reproduction_statement

      { 'use and reproduction' => [use_and_reproduction_statement] }
    end

    def license_statement_hash
      return {} unless license_statement

      { 'license' => [license_statement] }
    end

    def use_and_reproduction_statement
      @use_and_reproduction_statement ||=
        @document.cocina_record.path('$.access.useAndReproductionStatement').to_a.first
    end

    def license_statement
      return unless licence_url

      @license_statement ||= LicenseService.call(url: licence_url)
    end

    def licence_url
      @document.cocina_record.path('$.access.license').to_a.first
    end
  end
end
