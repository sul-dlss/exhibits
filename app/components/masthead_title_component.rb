# frozen_string_literal: true

# Draws the title in the masthead
class MastheadTitleComponent < ViewComponent::Base
  def initialize(title:, subtitle:)
    @title = title
    @subtitle = subtitle
    super
  end

  def title
    tag.h1 link(@title), class: 'site-title h2'
  end

  def subtitle
    return unless @subtitle

    tag.small link(@subtitle), class: 'py-2 fs-4'
  end

  private

  def link(link_text)
    return link_to link_text, helpers.spotlight.exhibit_path(helpers.current_exhibit) if helpers.current_exhibit

    link_to link_text, helpers.spotlight.exhibits_path
  end
end
