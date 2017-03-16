###
# A controller to handle any external services that need to be configured by an admin
class ServicesController < Spotlight::ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource :exhibit, class: Spotlight::Exhibit
  before_action :build_resource
  load_and_authorize_resource :bibliography_service, through: :exhibit, singleton: true

  def edit; end

  def update
    if @bibliography_service.update(update_params)
      redirect_to edit_exhibit_services_path(@exhibit), notice: I18n.t('services.update.notice')
    else
      redirect_to edit_exhibit_services_path(@exhibit), alert: I18n.t('services.update.error')
    end
  end

  def create
    if @bibliography_service.update(update_params)
      redirect_to edit_exhibit_services_path(@exhibit), notice: I18n.t('services.create.notice')
    else
      redirect_to edit_exhibit_services_path(@exhibit), alert: I18n.t('services.create.error')
    end
  end

  private

  def build_resource
    @bibliography_service = if @exhibit.bibliography_service
                              @exhibit.bibliography_service
                            else
                              ::BibliographyService.new(exhibit_id: @exhibit.id)
                            end
  end

  def update_params
    params.require(:bibliography_service).permit(:header, :api_id, :api_type)
  end
end
