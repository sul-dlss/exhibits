# :nodoc:
class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include Spotlight::Catalog::AccessControlsEnforcement::SearchBuilder
end
