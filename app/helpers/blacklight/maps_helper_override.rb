# frozen_string_literal: true

module Blacklight
  # Override Blacklight::MapsHelper from blacklight_heatmaps
  module MapsHelperOverride
    private

    ##
    # Build a parameterized path for the solr documents
    # and avoid Rails URL escaping by using a temporary token, and then substituting the actual value.
    def document_path
      token = '__id__'
      original_path = spotlight.exhibit_solr_document_path(exhibit_id: current_exhibit, id: token)
      original_path.sub(token, "{#{blacklight_config.document_model.unique_key}}")
    end

    def index_map_data_attributes
      attributes = super
      if controller.is_a? Spotlight::BrowseController
        attributes[:search_url] = spotlight.search_exhibit_catalog_url(
          controller.send(:search_query).merge(search_field: 'search')
        )
      end
      attributes
    end
  end
end
