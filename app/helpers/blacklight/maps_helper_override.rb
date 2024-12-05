# frozen_string_literal: true

module Blacklight
  # Override Blacklight::MapsHelper from blacklight_heatmaps
  module MapsHelperOverride
    def sidebar_template
      <<-HTMLTEMPLATE
      <li>
        <h3 class='index_title document-title-heading'>
          <a href="{url}">{title}</a>
        </h3>
      </li>
      HTMLTEMPLATE
    end

    private

    ##
    # Build a parameterized path for the solr documents
    # and avoid Rails URL escaping by using a temporary token, and then substituting the actual value.
    def document_path
      token = '__id__'
      original_path = spotlight.exhibit_solr_document_path(exhibit_id: current_exhibit, id: token)
      original_path.sub(token, "{#{blacklight_config.document_model.unique_key}}")
    end
  end
end
