# frozen_string_literal: true

##
# Class for handling BibliographyResourcesController
class BibliographyResourcesController < Spotlight::ResourcesController
  before_action :authenticate_user!
  load_and_authorize_resource :exhibit, class: Spotlight::Exhibit
  skip_load_resource
  before_action :build_resource
  authorize_resource

  def create
    @resource.update(bibtex_file: resource_params[:bibtex_file].read)

    if @resource.save_and_index
      redirect_to spotlight.admin_exhibit_catalog_path(current_exhibit),
                  notice: I18n.t('bibliography_resources.create.notice')
    else
      redirect_to spotlight.new_exhibit_resource_path(current_exhibit),
                  alert: I18n.t('bibliography_resources.create.error')
    end
  end
  alias update create

  private

  def resource_class
    BibliographyResource
  end

  def build_resource
    @resource = BibliographyResource.find_or_initialize_by(exhibit: current_exhibit)
  end
end
