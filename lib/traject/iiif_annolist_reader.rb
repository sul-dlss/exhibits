# frozen_string_literal: true

# Reads in Annotation records from Annotation List for traject plus
class IIIFAnnolistReader
  # @param input_stream [File]
  # @param settings [Traject::Indexer::Settings]
  def initialize(input_stream, settings)
    @settings = Traject::Indexer::Settings.new settings
    @input_stream = input_stream
    @json = JSON.parse(input_stream.read)
    @settings['annolist_context'] = @json['@context']
    @settings['annolist_id'] = @json['@id']
    @settings['annolist_type'] = @json['@type']
  end

  attr_reader :json

  def each(&block)
    return to_enum(:each) unless block_given?

    if json['resources'].is_a? Array
      json['resources'].each(&block)
    else
      yield json['resources']
    end
  end
end
