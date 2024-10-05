# frozen_string_literal: true

class ExhibitNavbarComponent < Spotlight::ExhibitNavbarComponent
  def prepend_to_search_bar
    render SearchTipsLinkComponent.new
  end
end