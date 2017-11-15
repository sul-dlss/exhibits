# frozen_string_literal: true

##
# Mirador controller providing an iframeable Mirador
class MiradorController < ApplicationController
  before_action :set_manifest
  before_action :set_canvas
  layout false

  def index; end

  private

  def set_manifest
    @manifest = mirador_params
  end

  def set_canvas
    @canvas = params.require(:canvas) if params.require(:canvas)
  end

  def mirador_params
    params.require(:manifest)
  end
end
