# frozen_string_literal: true
class SavedSearchesController < ApplicationController #:nodoc:
  include Blacklight::SavedSearches

  helper BlacklightAdvancedSearch::RenderConstraintsOverride
end
