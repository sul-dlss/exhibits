##
# Controller providing a choice of viewers
class ViewersController < Spotlight::ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource :exhibit, class: Spotlight::Exhibit
  before_action :build_resource
  load_and_authorize_resource :viewer, through: :exhibit, singleton: true

  # GET /viewers/edit
  def edit
    add_breadcrumb t(:'spotlight.exhibits.breadcrumb', title: @exhibit.title), [spotlight, @exhibit]
    add_breadcrumb t(:'spotlight.configuration.sidebar.header'), spotlight.exhibit_dashboard_path(@exhibit)
    add_breadcrumb t(:'viewers.menu_link'), edit_exhibit_viewers_path(@exhibit)
  end

  # PATCH/PUT /viewers/1
  # PATCH/PUT /viewers/1.json
  def update
    if @viewer.update(viewer_params)
      redirect_to edit_exhibit_viewers_path(@exhibit), notice: I18n.t('viewers.update.notice')
    else
      redirect_to edit_exhibit_viewers_path(@exhibit), alert: I18n.t('viewers.update.error')
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def viewer_params
    params.require(:viewer).permit(:viewer_type, :custom_manifest_pattern)
  end

  def build_resource
    @viewer = Viewer.find_or_create_by(exhibit: @exhibit)
  end
end
