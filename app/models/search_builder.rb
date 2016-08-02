# :nodoc:
class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightHeatmaps::SolrFacetHeatmapBehavior

  include Spotlight::AccessControlsEnforcementSearchBuilder
end
