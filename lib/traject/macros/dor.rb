# frozen_string_literal: true

module Traject
  module Macros
    # Macros for working with DOR objects
    module Dor
      # Call a cocina_display method and accumulate the results
      # @param method [Symbol] the cocina_display method to call
      # @param args [Array] additional positional arguments to pass to the cocina_display method
      # @param kwargs [Hash] additional keyword arguments to pass to the cocina_display method
      # @example
      #   cocina_display(:pub_year_int, ignore_qualified: true)
      def cocina_display(method, *, **)
        lambda do |resource, accumulator, _context|
          Array(resource.cocina_record.public_send(method, *, **)).each do |v|
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
    end
  end
end
