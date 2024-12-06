# frozen_string_literal: true

# Draws the skip links for screen readers
class SkipLinkComponent < Blacklight::SkipLinkComponent
  # This is only needed until we are using https://github.com/projectblacklight/blacklight/pull/3461
  def link_classes
    'visually-hidden-focusable rounded-bottom py-2 px-3'
  end
end
