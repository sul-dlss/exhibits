# frozen_string_literal: true

##
# BibliographyResource model class
class BibliographyResource < Spotlight::Resource
  store :data, accessors: [:bibtex_file]

  def self.indexing_pipeline
    @indexing_pipeline ||= super.dup.tap do |pipeline|
      pipeline.sources = [
        Spotlight::Etl::Sources::SourceMethodSource(:traject_reader)
      ]

      pipeline.transforms = [
        lambda do |data, p|
          doc = p.context.resource.traject_indexer.map_record(p.source)&.symbolize_keys

          throw(:skip) unless doc

          data.merge(doc.merge(id: Array(doc[:id]).first))
        end
      ] + pipeline.transforms
    end
  end

  ##
  # A basic first implementation, this should be configured with an input stream
  # based on some model value
  def traject_reader
    traject_indexer.reader!(
      StringIO.new(bibtex_file).set_encoding('UTF-8')
    )
  end

  def traject_indexer
    @traject_indexer ||= Traject::Indexer.new('exhibit_slug' => exhibit.slug).tap do |i|
      i.load_config_file('lib/traject/bibtex_config.rb')
    end
  end
end
