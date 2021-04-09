# frozen_string_literal: true

# This unpleasantness allows us to include the upstream class before overriding it
spotlight_path = Gem::Specification.find_by_name('blacklight-spotlight').full_gem_path
require_dependency File.join(spotlight_path, 'app/models/spotlight/resources/iiif_manifest.rb')

require 'iiif/hash_behaviours'
module IIIF
  # monkey-patch pending https://github.com/iiif-prezi/osullivan/pull/78
  module HashBehaviours
    def_delegators :@data, :dig
  end
end

module Spotlight
  module Resources
    ##
    # A PORO to construct a solr hash for a given IiifManifest
    class IiifManifest
      def add_thumbnail_url
        return unless thumbnail_field

        # if a thumbnail service is available
        image = manifest['thumbnail'] if iiif_thumbnail_service?(manifest['thumbnail'])

        # Else, use the first canvas
        # if IIIF Presentation v2
        image ||= manifest.dig('sequences', 0, 'canvases', 0, 'images', 0, 'resource')

        # IIIF Presentation v3
        image ||= manifest.dig('items', 0, 'items', 0, 'items', 0, 'body')
        return unless image

        iiif_image = image['service'] || {}
        if iiif_thumbnail_service?(image)
          solr_hash[:thumbnail_square_url_ssm] =
            "#{iiif_image['@id']}/full/100,100/0/default.jpg"
          solr_hash[:large_image_url_ssm] =
            "#{iiif_image['@id']}/full/!1000,1000/0/default.jpg"
        end
        solr_hash[thumbnail_field] = image['@id'] || "#{iiif_image['@id']}/full/!400,400/0/default.jpg"
      end

      def iiif_thumbnail_service?(content_resource)
        return unless content_resource.respond_to?(:dig)

        content_resource&.dig('service', 'profile')&.match? 'api/image'
      end
    end
  end
end
