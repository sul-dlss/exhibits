# frozen_string_literal: true

# This unpleasantness allows us to include the upstream class before overriding it
spotlight_path = Gem::Specification.find_by_name('blacklight-spotlight').full_gem_path
require_dependency File.join(spotlight_path, 'app/models/spotlight/resources/iiif_manifest.rb')

module Spotlight
  module Resources
    ##
    # A PORO to construct a solr hash for a given IiifManifest
    class IiifManifest
      def add_thumbnail_url
        return unless thumbnail_field

        image = manifest['thumbnail'] if manifest['thumbnail'].present?
        image ||= manifest.dig('sequences', 0, 'canvases', 0, 'images', 0, 'resource')

        return unless image

        iiif_image = image['service']
        if iiif_image['profile']&.match? 'api/image'
          solr_hash[:thumbnail_square_url_ssm] =
            "#{iiif_image['@id']}/full/100,100/0/default.jpg"
          solr_hash[:large_image_url_ssm] =
            "#{iiif_image['@id']}/full/!1000,1000/0/default.jpg"
        end
        solr_hash[thumbnail_field] = image['@id'] || "#{iiif_image['@id']}/full/!400,400/0/default.jpg"
      end
    end
  end
end
