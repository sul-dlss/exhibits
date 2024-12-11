# frozen_string_literal: true

# Search tips link for the catalog navbar
class SearchTipsLinkComponent < ViewComponent::Base
  def search_tips_path
    helpers.search_tips_exhibit_catalog_path(exhibit:)
  end

  def exhibit
    helpers.current_exhibit
  end
end
