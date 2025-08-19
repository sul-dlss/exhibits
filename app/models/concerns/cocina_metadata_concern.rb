# frozen_string_literal: true

##
# Convenience methods for metadata access
module CocinaMetadataConcern
  delegate :cocina_record, :public_cocina, to: :purl

  def purl
    @purl ||= Purl.new(id)
  end
end
