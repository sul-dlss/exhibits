# frozen_string_literal: true

##
# Provide the GitHub auto-complete-element response for exhibit autocomplete and bento
class ExhibitAutocompleteController < ApplicationController
  # /exhibit_autocomplete
  def index
    @exhibits = ExhibitFinder.search(params[:q]).as_json
    render layout: false
  end
end
