# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CustomEmbedDocumentComponent do
  # ViewComponent may compile (and validate) a component's superclasses when rendering it,
  # depending on what has already been compiled, so check the whole chain directly.
  it 'only inherits from components that accept the document collection parameter' do
    components = described_class.ancestors.grep(Class).select { |klass| klass <= ViewComponent::Base && klass != ViewComponent::Base }

    expect { components.each(&:validate_collection_parameter!) }.not_to raise_error
  end
end
