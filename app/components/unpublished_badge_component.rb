# frozen_string_literal: true

# Badge flagging an exhibit as unpublished
class UnpublishedBadgeComponent < ViewComponent::Base
  # @param html_options [Hash] HTML attributes for the badge; :class is appended to the default badge classes
  def initialize(**html_options)
    super()
    @html_options = html_options
  end

  def call
    tag.span(t('catalog.index.unpublished'),
             **@html_options, class: ['badge', 'text-bg-warning', @html_options[:class]].compact)
  end
end
