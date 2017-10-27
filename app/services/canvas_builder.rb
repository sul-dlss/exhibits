# frozen_string_literal: true

##
# Custom Canvas for indexing AnnotationList records coming from Traject
class CanvasBuilder < Spotlight::SolrDocumentBuilder
  include ActiveSupport::Benchmarkable
  delegate :logger, to: :Rails
  delegate :size, to: :traject_reader

  def to_solr
    return to_enum(:to_solr) { size } unless block_given?

    benchmark "Indexing resource #{inspect}" do
      base_doc = super
      traject_reader.each do |record|
        doc = convert_id(traject_indexer.map_record(record))
        yield base_doc.merge(doc) if doc
      end
    end
  end

  def traject_reader
    traject_indexer.reader!(StringIO.new(resource.data.to_json).set_encoding('UTF-8'))
  end

  def traject_indexer
    Traject::Indexer.new('exhibit_slug' => resource.exhibit.slug).tap do |i|
      i.load_config_file('lib/traject/canvas_config.rb')
    end
  end

  private

  def convert_id(doc)
    doc[:id] = doc['id'].try(:first)
    doc
  end
end
