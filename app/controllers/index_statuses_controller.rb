# frozen_string_literal: true

##
# A controller to list/filter document druids and display that items indexing status
class IndexStatusesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource :exhibit, class: Spotlight::Exhibit
  before_action :build_resource

  before_action do
    # This is what authorize_resource should be doing for us, but does not work for :index
    authorize!(params[:action].to_sym, @resource)
  end

  def show
    document = @resource.solr_document_sidecars.where(document_id: params[:id]).first
    raise ActionController::RoutingError, "No document with id \"#{params[:id]}\" found" unless document

    render json: {
      id: params[:id],
      status: document.index_status
    }
  end

  def index
    render json: filtered_solr_document_ids
  end

  private

  def build_resource
    @resource = DorHarvester.instance(current_exhibit)
  end

  def filtered_solr_document_ids
    document_ids = @resource.solr_document_sidecars.pluck(:document_id)
    return document_ids unless params[:q]
    index_query_param = params[:q].downcase

    document_ids.select { |id| id.include?(index_query_param) }
  end
end
