# :nodoc:
class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightHeatmaps::SolrFacetHeatmapBehavior

  include Spotlight::AccessControlsEnforcementSearchBuilder

  self.default_processor_chain += [:add_mm_for_boolean_or_queries]

  # In Solr 5.5, the way edismax parsed boolean OR queries was changed in https://issues.apache.org/jira/browse/SOLR-2649
  # from behavior that always set the `mm` parameter to 0 (meaning all terms optional), to
  # new behavior that only set the `mm` parameter if it wasn't set in the request handler or in parameters.
  #
  # The behavior was beneficial for many types of queries (particularly using `NOT` and `AND`), but breaks the expected
  # behavior of `OR` for many simple queries (e.g. "this OR that" is now affected by the `mm` parameter, instead of as
  # a simple boolean query for documents matching one or both terms). (see https://issues.apache.org/jira/browse/SOLR-9174)
  #
  # This is an attempt to restore the previous boolean OR behavior for certainly types of queries in an attempt to
  # preserve the improved `AND` and `NOT` support, while still supporting the expected boolean OR behavior in others.
  def add_mm_for_boolean_or_queries(solr_parameters)
    return if blacklight_params[:q].blank?

    solr_parameters[:mm] = 0 if blacklight_params[:q] =~ / OR / && blacklight_params[:q] !~ / (NOT|AND) /
  end
end
