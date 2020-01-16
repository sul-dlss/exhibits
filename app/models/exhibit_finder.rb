# frozen_string_literal: true

##
# ExhibitFinder takes in a druid as the document_id and finds any published
# Exhibit that contains that document or is a document in the given collection
class ExhibitFinder
  attr_reader :document_id
  def initialize(document_id)
    @document_id = document_id
  end

  def exhibits
    @exhibits ||= Spotlight::Exhibit.includes(:thumbnail).where(slug: exhibit_slugs).published
  end

  def as_json(*)
    exhibits.map do |exhibit|
      exhibit.as_json.merge(
        'thumbnail_url' => exhibit&.thumbnail&.iiif_url
      )
    end
  end

  private

  def exhibit_slugs
    documents.collect do |document|
      document[exhibit_slug_field]&.select do |slug|
        document[exhibit_public_field(slug)]&.all?
      end
    end.flatten.compact.uniq
  end

  def documents
    @documents ||= solr_connection.select(
      params: {
        q: "(id:#{document_id} OR collection:#{document_id})",
        fl: ['id', exhibit_slug_field, exhibit_public_field],
        facet: false,
        rows: 10_000
      }
    ).dig('response', 'docs') || []
  end

  def solr_connection
    Blacklight.default_index.connection
  end

  def exhibit_public_field(slug = '*')
    "exhibit_#{slug}_public_bsi"
  end

  def exhibit_slug_field
    'spotlight_exhibit_slugs_ssim'
  end
end
