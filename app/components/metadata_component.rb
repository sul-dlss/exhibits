# frozen_string_literal: true

# Render a metadata label value pair
class MetadataComponent < ViewComponent::Base
  def initialize(field_labels_with_values:)
    @field_labels_with_values = field_labels_with_values
    super
  end

  attr_reader :field_labels_with_values
end
