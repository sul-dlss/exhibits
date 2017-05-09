###
# A controller to handle any external services that need to be configured by an admin
class ServicesController < Spotlight::ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource :exhibit, class: Spotlight::Exhibit
  before_action :build_resource
  load_and_authorize_resource :bibliography_service, through: :exhibit, singleton: true

  def edit
    add_breadcrumb t(:'spotlight.exhibits.breadcrumb', title: @exhibit.title), [spotlight, @exhibit]
    add_breadcrumb t(:'spotlight.configuration.sidebar.header'), spotlight.exhibit_dashboard_path(@exhibit)
    add_breadcrumb t(:'services.menu_link'), edit_exhibit_services_path(@exhibit)
  end

  def update
    if @bibliography_service.update_and_sync_bibliography(update_params)
      redirect_to edit_exhibit_services_path(@exhibit), notice: I18n.t('services.update.notice')
    else
      redirect_to edit_exhibit_services_path(@exhibit), alert: I18n.t('services.update.error')
    end
  end

  def create
    if @bibliography_service.update_and_sync_bibliography(update_params)
      redirect_to edit_exhibit_services_path(@exhibit), notice: I18n.t('services.create.notice')
    else
      redirect_to edit_exhibit_services_path(@exhibit), alert: I18n.t('services.create.error')
    end
  end

  def sync
    @exhibit.sync_bibliography
    redirect_to edit_exhibit_services_path(@exhibit), notice: I18n.t('services.sync.started')
  end

  private

  def build_resource
    @bibliography_service = @exhibit.bibliography_service || @exhibit.build_bibliography_service
  end

  def update_params
    params.require(:bibliography_service).permit(:header, :api_id, :api_type)
  end
end
