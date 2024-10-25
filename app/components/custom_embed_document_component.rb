# frozen_string_literal: true

# Customize the upstream component to pass the block context through the embed
class CustomEmbedDocumentComponent < Spotlight::SolrDocumentLegacyEmbedComponent
  attr_reader :block_context

  def initialize(*args, block: nil, **kwargs)
    super

    @block_context = block
  end

  def before_render
    set_slot(:embed, nil, block_context: block_context) unless embed

    super
  end
end
