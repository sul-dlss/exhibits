# frozen_string_literal: true

# Overriding the skip link component to use the component library classes
class SkipLinkComponent < Blacklight::SkipLinkComponent
  # This is only needed until we are using https://github.com/projectblacklight/blacklight/pull/3461
  def link_classes
    'd-inline-flex m-1 py-2 px-3'
  end

  # This overrides the <%= content %> line since the styling of that link
  # uses the Blacklight styles by default
  def link_to_content
    link_to t('blacklight.skip_links.first_result'), '#documents', class: link_classes
  end
end
