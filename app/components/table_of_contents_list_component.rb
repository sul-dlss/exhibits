# frozen_string_literal: true

# Renders table of contents entries in a collapsible list
class TableOfContentsListComponent < ViewComponent::Base
  def initialize(contents:, collapse_id:)
    @contents = contents
    @collapse_id = collapse_id
    super()
  end

  attr_reader :collapse_id

  def items
    safe_join(@contents.map { |v| "<li>#{v}</li>".html_safe }) # rubocop:disable Rails/OutputSafety
  end
end
