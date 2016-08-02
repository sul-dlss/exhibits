module Blacklight
  # Override Blacklight::MapsHelper from blacklight_heatmaps
  module MapsHelperOverride
    private

    def document_path
      exhibit_solr_document_path(exhibit: current_exhibit, id: :id)
    end
  end
end
