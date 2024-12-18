# frozen_string_literal: true

# Overrides Spotlight ExhibitNavbarComponent and provides Search Tips link
class ExhibitNavbarComponent < Spotlight::ExhibitNavbarComponent
  def render?
    helpers.should_render_spotlight_search_bar?
  end
end
