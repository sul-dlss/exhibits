# frozen_string_literal: true

##
# Controller providing MODS metadata display features
class MetadataController < Spotlight::CatalogController
  before_action :load_response

  ##
  # A simplification of Blacklight's `Blacklight::CatalogController#show` and
  # `Blacklight:DefaultComponentConfiguration#add_show_tools_partial` method for
  # our `metadata` which is not defined as a "Blacklight show tool".
  # https://github.com/projectblacklight/blacklight/blob/v6.12.0/app/controllers/concerns/blacklight/default_component_configuration.rb#L42-L73
  def show
    respond_to do |format|
      format.html do
        return render layout: false if request.xhr?
      end
    end
  end

  def attach_breadcrumbs
    load_response

    title = Array(@document[blacklight_config.view_config(:show).title_field]).join(', ')
    add_breadcrumb title, spotlight.polymorphic_path([current_exhibit, @document])
    add_breadcrumb t('metadata.breadcrumb')
  end

  def search_action_url(options = {})
    spotlight.search_exhibit_catalog_url(options.except(:controller, :action))
  end

  def load_response
    return if @response

    @response, @document = search_service.fetch(params[:id])
  end
end
