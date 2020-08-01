# frozen_string_literal: true

module Traject
  module Macros
    # Helpers for traject mappings & normalization for Parker, stolen from DLME
    module Extraction
      def self.apply_extraction_options(result, options = {})
        TransformPipeline.new(options).transform(result)
      end

      # Pipeline for transforming extracted values into normalized values
      class TransformPipeline
        attr_reader :options

        def append(values, append_string)
          values.flat_map do |v|
            "#{v}#{append_string}"
          end
        end

        def default(values, default_value)
          values.presence || default_value
        end

        def initialize(options)
          @options = options
        end

        def insert(values, insert_string)
          values.flat_map do |v|
            insert_string.gsub('%s', v)
          end
        end

        def match(values, regex)
          values.map.grep(regex)
        end

        def replace(values, options)
          values.flat_map do |v|
            v.gsub(options[0], options[1])
          end
        end

        def split(*values, splitter)
          values.flat_map do |v|
            v.split(splitter)
          end
        end

        def transform(values)
          options.inject(values) { |memo, (step, params)| public_send(step, memo, params) }
        end

        def translation_map(values, maps)
          translation_map = Traject::TranslationMap.new(*Array(maps))
          # without overwriting (further) translation map, could add
          # fuzzy match method here after pulling array out of TM
          values = Array(values).map(&:downcase)
          translation_map.translate_array values
        end

        def trim(values, _)
          values.map(&:strip)
        end
      end
    end
  end
end
