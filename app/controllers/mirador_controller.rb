# frozen_string_literal: true

##
# Mirador controller providing an iframeable Mirador
class MiradorController < ApplicationController
  before_action :set_manifest
  layout false

  def index; end

  private

  def set_manifest
    @manifest = mirador_params
  end

  def mirador_params
    params.require(:manifest)
  end
end
