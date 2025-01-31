# frozen_string_literal: true

class SelectImageAreaController < ApplicationController
  include Blacklight::Configurable
  include Spotlight::Concerns::ApplicationController
  include Blacklight::Catalog

  before_action :authenticate_user!
  load_and_authorize_resource :exhibit, class: Spotlight::Exhibit

  configure_blacklight do |config|
    config.show.oembed_field = CatalogController.blacklight_config.show.oembed_field
  end

  def show
    begin
      result = search_service.fetch params[:id]
      @document = if result.is_a?(Array)
                    result.last
                  else
                    result
                  end
    rescue StandardError
      @document = nil
    end
    respond_to do |format|
      format.html do
        return render layout: false if request.xhr?
        # Otherwise draw the full page
      end
    end
  end

  def select_image_area_params
    params.permit(:form_id, :item_id, :canvas_id, :id, :exhibit_id, :url)
  end
end
