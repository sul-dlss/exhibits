# frozen_string_literal: true

# This unpleasantness allows us to include the upstream class before overriding it
# rubocop:disable Rails/DynamicFindBy
spotlight_path = Gem::Specification.find_by_name('blacklight-spotlight').full_gem_path
require_dependency File.join(spotlight_path, 'app/models/spotlight/resources/iiif_manifest.rb')
# rubocop:enable Rails/DynamicFindBy

module Spotlight
  module Resources
    ##
    # A PORO to construct a solr hash for a given IiifManifest
    class IiifManifest
      def add_thumbnail_url
        return unless thumbnail_field && manifest['thumbnail'].present?

        if manifest&.[]('thumbnail')&.[]('service')&.[]('profile')&.match? 'api/image'
          solr_hash[:thumbnail_square_url_ssm] =
            "#{manifest&.[]('thumbnail')&.[]('service')&.[]('@id')}/square/100,100/0/default.jpg"
        end
        solr_hash[thumbnail_field] = manifest['thumbnail']['@id']
      end
    end
  end
end
