# frozen_string_literal: true

# Overriding the skip link component to use the component library classes
class SkipLinkComponent < Blacklight::SkipLinkComponent
  # This is only needed until we are using https://github.com/projectblacklight/blacklight/pull/3461
  def link_classes
    'visually-hidden-focusable rounded-bottom py-2 px-3'
  end
end
