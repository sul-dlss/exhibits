# frozen_string_literal: true

##
# Custom Bibliography class used for indexing Bibliography records coming from
# Traject.
class BibliographyBuilder < Spotlight::SolrDocumentBuilder
  def to_solr
    return to_enum(:to_solr) unless block_given?
    traject_reader.each do |record|
      yield traject_indexer.map_record(record)
    end
  end

  ##
  # A basic first implementation, this should be configured with an input stream
  # based on some model value
  def traject_reader
    traject_indexer.reader!(
      File.open(
        Rails.root.join('spec', 'fixtures', 'bibliography', resource.url)
      )
    )
  end

  def traject_indexer
    Traject::Indexer.new('exhibit_slug' => resource.exhibit.slug).tap do |i|
      i.load_config_file('lib/traject/bibtex_config.rb')
    end
  end
end
