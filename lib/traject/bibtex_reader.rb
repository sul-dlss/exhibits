# frozen_string_literal: true

module Traject
  # Reads in BibTex records for traject
  class BibtexReader
    # @param input_stream [File]
    # @param settings [Traject::Indexer::Settings]
    def initialize(input_stream, settings)
      @settings = Traject::Indexer::Settings.new settings
      @input_stream = input_stream
      @bibliography = Bibliography.new(input_stream.read)
    end

    # @return [BibTeX::Entry]
    def each(&block)
      bibliography.bibliography.each(&block)
    end

    def count
      size
    end

    def size
      bibliography.bibliography.size
    end

    attr_reader :bibliography
  end
end
