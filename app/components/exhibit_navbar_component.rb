# frozen_string_literal: true

# Overrides Spotlight ExhibitNavbarComponent and provides Search Tips link
class ExhibitNavbarComponent < Spotlight::ExhibitNavbarComponent
  def prepend_to_search_bar
    render SearchTipsLinkComponent.new
  end
end
