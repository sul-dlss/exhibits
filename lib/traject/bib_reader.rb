# frozen_string_literal: true

# Reads in BibTex records for traject
class BibReader
  # @param input_stream [File]
  # @param settings [Traject::Indexer::Settings]

  delegate :size, to: :bibtex

  def initialize(input_stream, settings)
    @settings = Traject::Indexer::Settings.new settings
    @input_stream = input_stream
    @bibtex = BibTeX.parse(input_stream.read, filter: :latex)
  end

  def each(&block)
    bibtex.each(&block)
  end

  attr_reader :bibtex
end
