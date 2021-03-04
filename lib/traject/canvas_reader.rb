# frozen_string_literal: true

module Traject
  # Reads in Canvas records for traject
  class CanvasReader
    # @param input_stream [File|IO] An enhanced IIIF Canvas object
    # @param settings [Traject::Indexer::Settings]
    def initialize(input_stream, settings)
      @settings = Traject::Indexer::Settings.new settings
      @input_stream = input_stream
      @data = Array.wrap(JSON.parse(input_stream.read))
    end

    attr_reader :data
    delegate :each, :size, to: :data

    def count
      size
    end
  end
end
