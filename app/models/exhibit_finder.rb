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
    @exhibits ||= Spotlight::Exhibit.includes(:thumbnail).where(slug: exhibit_slugs).published.discoverable
  end

  class << self
    def find(document_id)
      ExhibitFinder::JsonResponse.new(
        new(document_id).exhibits
      )
    end

    def search(query)
      slugs = exhibit_slugs_for_search(query)

      ExhibitFinder::JsonResponse.new(
        Spotlight::Exhibit.includes(:thumbnail).where(slug: slugs).sort do |a, b|
          slugs.index(a.slug) <=> slugs.index(b.slug) # sort the exhibits by the order of the slugs/results in solr
        end
      )
    end

    private

    def exhibit_slugs_for_search(query)
      query = "#{query} OR #{query}*"

      documents = Blacklight.default_index.connection.select(
        params: {
          q: query,
          qt: 'exhibit-titles',
          rows: 5,
          fl: 'exhibit_slug_ssi'
        }
      ).dig('response', 'docs') || {}

      documents.map { |document| document['exhibit_slug_ssi'] }
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
        fq: '-document_type_ssi:exhibit',
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

  ##
  # Serialize the exhibits into JSON that includes additional attributes (e.g. thumbnail URL)
  class JsonResponse
    def initialize(exhibits)
      @exhibits = exhibits
    end

    def as_json(*)
      @exhibits.map do |exhibit|
        exhibit.as_json.merge(
          'thumbnail_url' => exhibit&.thumbnail&.iiif_url
        )
      end
    end
  end
end
