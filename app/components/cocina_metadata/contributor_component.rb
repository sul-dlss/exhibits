# frozen_string_literal: true

# Render the Cocina metadata component
module CocinaMetadata
  # Renders the contributor section for Cocina metadata display
  class ContributorComponent < ViewComponent::Base
    ROLES_TO_EXCLUDE = ['publisher'].freeze

    def initialize(document:)
      @document = document
      super()
    end

    def call
      render MetadataComponent.new(field_labels_with_values:)
    end

    def metadata?
      field_labels_with_values.any?
    end

    private

    # TODO: This probably isn't quite right because the cocina display method
    # excludes contributors without roles.
    def field_labels_with_values
      (@document.cocina_record.contributor_names_by_role(with_date: true) || []).except(*ROLES_TO_EXCLUDE)
    end
  end
end
