# frozen_string_literal: true

# Toggle between ungrouped results and results grouped by exhibit on the search across page
class GroupToggleComponent < ViewComponent::Base
  # @param [Blacklight::Solr::Response] response
  # @param [Blacklight::SearchState] search_state
  def initialize(response:, search_state:)
    @response = response
    @search_state = search_state
    super()
  end

  def render?
    @response.documents.present?
  end

  def search_without_group
    @search_state.params_for_search.except(:group)
  end

  def search_with_group
    @search_state.params_for_search.merge(group: true)
  end

  # Read the request params directly: depending on load order, SearchAcrossController's
  # search_state_fields may not include :group, so search_state.params can drop it.
  def grouped?
    params[:group].present?
  end
end
