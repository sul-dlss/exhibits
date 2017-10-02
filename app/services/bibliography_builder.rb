# frozen_string_literal: true

##
# Custom Bibliography class used for indexing Bibliography records coming from
# Traject.
class BibliographyBuilder < Spotlight::SolrDocumentBuilder
  include ActiveSupport::Benchmarkable
  delegate :logger, to: :Rails

  def to_solr
    return to_enum(:to_solr) unless block_given?

    benchmark "Indexing resource #{inspect}" do
      base_doc = super
      traject_reader.each do |record|
        doc = convert_id(traject_indexer.map_record(record))
        yield base_doc.merge(doc) if doc
      end
    end
  end

  ##
  # A basic first implementation, this should be configured with an input stream
  # based on some model value
  def traject_reader
    traject_indexer.reader!(
      StringIO.new(resource.bibtex_file).set_encoding('UTF-8')
    )
  end

  def traject_indexer
    Traject::Indexer.new('exhibit_slug' => resource.exhibit.slug).tap do |i|
      i.load_config_file('lib/traject/bibtex_config.rb')
    end
  end

  private

  def convert_id(doc)
    return unless doc['id']
    doc[:id] = doc['id'].first
    doc
  end
end
