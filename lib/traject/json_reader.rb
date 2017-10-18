# frozen_string_literal: true

# Reads in JSON records for traject plus
class JsonReader
  # @param input_stream [File]
  # @param settings [Traject::Indexer::Settings]
  def initialize(input_stream, settings)
    @settings = Traject::Indexer::Settings.new settings
    @input_stream = input_stream
    @json = JSON.parse(input_stream.read)
  end

  attr_reader :json

  def each(&block)
    return to_enum(:each) unless block_given?

    if json.is_a? Array
      json.each(&block)
    else
      yield json
    end
  end
end
