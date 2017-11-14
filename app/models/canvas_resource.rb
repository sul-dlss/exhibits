# frozen_string_literal: true

##
# CanvasResource model class
class CanvasResource < Spotlight::Resource
  self.document_builder_class = CanvasBuilder

  store :data
end
