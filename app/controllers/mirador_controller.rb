# frozen_string_literal: true

##
# Mirador controller providing an iframeable Mirador
class MiradorController < ApplicationController
  before_action :set_mirador_params
  layout false

  def index; end

  private

  def set_mirador_params
    @manifest = params.require(:manifest)
    @canvas = params.fetch(:canvas, nil)
    @exhibit_slug = params.fetch(:exhibit_slug)
  end
end
