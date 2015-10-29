class PurlResourcesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource :exhibit, class: Spotlight::Exhibit
  before_action :build_resource
  authorize_resource

  def create
    if @resource.save
      redirect_to spotlight.admin_exhibit_catalog_index_path(current_exhibit)
    else
      render 'edit'
    end
  end

  private

  def build_resource
    @resource = begin
      r = PurlResource.new resource_params
      r.exhibit = current_exhibit
      r
    end
  end

  def resource_params
    params.require(:purl_resource).permit(:data)
  end
end
