# frozen_string_literal: true

# :nodoc:
class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightRangeLimit::RangeLimitBuilder

  include BlacklightAdvancedSearch::AdvancedSearchBuilder
  self.default_processor_chain += [:add_advanced_parse_q_to_solr, :add_advanced_search_to_solr]
  # include BlacklightHeatmaps::SolrFacetHeatmapBehavior

  include Spotlight::SearchBuilder
  self.default_processor_chain += [:limit_to_exhibit_items]

  ##
  # modify JSON API behavior to limit the `rows` (or `per_page`) parameter
  # to `max_per_page_for_api` (default: 1,000). if `rows` is not provided
  # we use `default_per_page`
  def rows(value = nil)
    return super if value || blacklight_params[:format] != 'json'

    @rows = [:rows, :per_page].map { |k| blacklight_params[k] }.reject(&:blank?).first
    @rows = if @rows.blank?
              blacklight_config.default_per_page
            else
              [@rows.to_i, blacklight_config.max_per_page_for_api || 1_000].min # ensure under max
            end
  end

  def limit_to_exhibit_items(solr_params)
    solr_params.append_filter_query '-document_type_ssi:exhibit'
  end
end
