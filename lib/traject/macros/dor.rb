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
    end
  end
end
