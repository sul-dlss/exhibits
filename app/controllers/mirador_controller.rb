##
# Mirador controller providing an iframeable Mirador
class MiradorController < ApplicationController
  before_action :set_manifest_url
  layout :false

  def index; end

  private

  def set_manifest_url
    @manifest_url = mirador_params
  end

  def mirador_params
    params.require(:manifest_url)
  end
end
