# frozen_string_literal: true

##
# A claass to index exhibit metadata (and related)
# You must pass an instance of an exhibit in the initializer
# ExhibitIndexer.new(exhibit)
# There is an #add method that will add/update the document in the index for that exhibit.
# There is also a #delete method that will delete the document for that exhibit (by id).
# The indexer will commit by default (since it runs in a background job), but if you're indexing
# in batches you you may want to commit after, in that case you can initialize the indexer with commit: false
# ExhibitIndexer.new(exhibit, commit: false).add
class ExhibitIndexer
  attr_accessor :exhibit
  attr_reader :commit

  def initialize(exhibit, commit: true)
    @exhibit = exhibit
    @commit = commit
  end

  def to_solr
    fields.merge(type_field).merge(id_field).reject { |_, v| v.blank? }
  end

  def delete
    self.class.solr_connection.delete_by_id(document_id)
    self.class.solr_connection.commit if commit
  end

  def add
    self.class.solr_connection.add(to_solr)
    self.class.solr_connection.commit if commit
  end

  def self.solr_connection
    @solr_connection ||= Blacklight.default_index.connection
  end

  private

  def fields
    {
      exhibit_title_tesim: exhibit.title,
      exhibit_subtitle_tesim: exhibit.subtitle,
      exhibit_description_tesim: exhibit.description,
      exhibit_slug_ssi: exhibit.slug
    }
  end

  def document_id
    "exhibit-#{exhibit.slug}"
  end

  def id_field
    { id: document_id }
  end

  def type_field
    { document_type_ssi: 'exhibit' }
  end
end
