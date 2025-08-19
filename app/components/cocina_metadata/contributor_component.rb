# frozen_string_literal: true

# Render the Cocina metadata component
module CocinaMetadata
  # Renders the contributor section for Cocina metadata display
  class ContributorComponent < ViewComponent::Base
    def initialize(document:)
      @document = document
      super()
    end

    def call
      render MetadataComponent.new(field_labels_with_values:)
    end

    def metadata?
      true
    end

    private

    # TODO: This probably isn't quite right because the cocina display method
    # excludes contributors without roles.
    # TODO: should publishers be removed?
    def field_labels_with_values
      @document.cocina_record.contributor_names_by_role(with_date: true) || []
    end
  end
end
