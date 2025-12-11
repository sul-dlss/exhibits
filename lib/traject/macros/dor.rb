# frozen_string_literal: true

module Traject
  module Macros
    # Macros for working with DOR objects
    module Dor
      def stanford_mods(method, *, **)
        lambda do |resource, accumulator, _context|
          Array(resource.smods_rec.public_send(method, *, **)).each do |v|
            accumulator << v
          end
        end
      end

      def resource_images_iiif_urls
        lambda do |resource, accumulator, _context|
          identifier = resource.public_xml.at_xpath('/publicObject/thumb')
          next if identifier.nil?

          accumulator << stacks_iiif_url(identifier.content.delete_suffix('.jp2'))
        end
      end

      private

      def stacks_iiif_url(identifier)
        "#{Settings.stacks.iiif_url}/#{ERB::Util.url_encode(identifier)}"
      end
    end
  end
end
