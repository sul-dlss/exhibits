# frozen_string_literal: true

require 'traject'

##
# A Traject writer for Bibliography resources
# https://github.com/traject/traject#readers-and-writers
class BibJsonResourceWriter
  attr_reader :settings, :exhibit

  delegate :logger, to: :Rails

  def initialize(arg_settings)
    @settings = Traject::Indexer::Settings.new(arg_settings)
    @exhibit = Spotlight::Exhibit.find_by!(slug: @settings.fetch('exhibit_slug'))
  end

  def put(context)
    attributes = context.output_hash.dup
    id = attributes.fetch('id').first
    json = JSON.generate(attributes).unicode_normalize
    CreateResourceJob.perform_later(id, exhibit, json)
  end
end
