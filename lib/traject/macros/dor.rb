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

      # Call a cocina_display method and accumulate the results
      # @param method [Symbol] the cocina_display method to call
      # @param kwargs [Hash] additional keyword arguments to pass to the cocina_display method
      # @example
      #   cocina_display(:pub_year_int, ignore_qualified: true)
      def cocina_display(method, **kwargs)
        lambda do |resource, accumulator, _context|
          Array(resource.cocina_record.public_send(method, **kwargs)).each do |v|
            accumulator << v
          end
        end
      end

      # Access Cocina record values at a JSON path expression and accumulate the results
      # @param path [String] the JSON path expression to evaluate
      # @example
      #   cocina_display_path('$.description.note[?match(@.type, "table of contents")].value')
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
