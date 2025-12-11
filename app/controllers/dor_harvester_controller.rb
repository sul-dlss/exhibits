# frozen_string_literal: true

##
# Resources controller allowing curators to create new
# exhibit resources from a list of DRUIDs.
class DorHarvesterController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource :exhibit, class: Spotlight::Exhibit
  before_action :build_resource
  authorize_resource

  def create
    @resource.update(resource_params)

    if @resource.save_and_index
      redirect_to spotlight.admin_exhibit_catalog_path(current_exhibit)
    else
      redirect_to spotlight.new_exhibit_resource_path(current_exhibit)
    end
  end
  alias update create

  private

  def build_resource
    @resource = DorHarvester.instance(current_exhibit)
  end

  def resource_params
    params.expect(dor_harvester: [:druid_list])
  end
end
