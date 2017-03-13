class ServicesController < Spotlight::ApplicationController

  load_and_authorize_resource :exhibit, class: Spotlight::Exhibit

  # TODO: load and authorize resource from CanCan
  # TODO: add something to the ability class
  def edit
    # render form
  end

  def update
    # process form
  end
end
