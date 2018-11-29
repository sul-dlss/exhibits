# frozen_string_literal: true

class SearchHistoryController < ApplicationController #:nodoc:
  include Blacklight::SearchHistory

  helper BlacklightAdvancedSearch::RenderConstraintsOverride
  helper BlacklightRangeLimit::ViewHelperOverride
  helper RangeLimitHelper
end
