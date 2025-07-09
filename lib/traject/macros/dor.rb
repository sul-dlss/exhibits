# frozen_string_literal: true

module Traject
  module Macros
    # Macros for working with DOR objects
    module Dor
      def stanford_mods(method, *args, **kwargs)
        lambda do |resource, accumulator, _context|
          Array(resource.smods_rec.public_send(method, *args, **kwargs)).each do |v|
            accumulator << v
          end
        end
      end

      def cocina_display(method, *args, **kwargs)
        lambda do |resource, accumulator, _context|
          Array(resource.cocina_record.public_send(method, *args, **kwargs)).each do |v|
            accumulator << v
          end
        end
      end

      def cocina_display_path(path)
        lambda do |resource, accumulator, _context|
          Array(resource.cocina_record.path(path)).each do |v|
            accumulator << v if v.present?
          end
        end
      end

      def resource_images_iiif_urls
        lambda do |resource, accumulator, _context|
          next if resource.thumbnail_identifier.nil?

          accumulator << resource.thumbnail_identifier
        end
      end
    end
  end
end
