# frozen_string_literal: true

module Macros
  # Macros for extracting IIIF specific values
  module IIIF
    def grab_iiif_manifest(manifest)
      ::DLME::Utils.fetch_json(manifest)
    end

    def iiif_thumbnail_id(iiif_json)
      iiif_json.dig('thumbnail', '@id')
    end

    def iiif_thumbnail_service_id(iiif_json)
      iiif_json.dig('thumbnail', 'service', '@id')
    end

    def iiif_thumbnail_service_protocol(iiif_json)
      iiif_json.dig('thumbnail', 'service', 'profile')
    end

    def iiif_thumbnail_service_conforms_to(iiif_json)
      iiif_service_conforms_to(iiif_json.dig('thumbnail', 'service', 'profile'))
    end

    def iiif_sequence_id(iiif_json)
      rep_iiif_resource(iiif_json).dig('@id')
    end

    def iiif_sequence_service_id(iiif_json)
      rep_iiif_resource(iiif_json).dig('service', '@id')
    end

    def iiif_sequence_service_protocol(iiif_json)
      rep_iiif_resource(iiif_json).dig('service', 'profile')
    end

    def iiif_sequence_service_conforms_to(iiif_json)
      iiif_service_conforms_to(rep_iiif_resource(iiif_json).dig('service', 'profile'))
    end

    def rep_iiif_resource(manifest_json)
      manifest_json['sequences'].first['canvases'].first['images'].first['resource'] || {}
    end

    def iiif_service_conforms_to(service_profile)
      # Using the thumbnail service profile for now
      if service_profile.include? 'http://iiif.io/api/image/'
        'http://iiif.io/api/image/'
      elsif service_profile.include? 'http://iiif.io/api/auth/'
        'http://iiif.io/api/auth/'
      elsif service_profile.include? 'http://iiif.io/api/presentation/'
        'http://iiif.io/api/presentation/'
      elsif service_profile.include? 'http://iiif.io/api/search/'
        'http://iiif.io/api/search/'
      end
    end
  end
end
