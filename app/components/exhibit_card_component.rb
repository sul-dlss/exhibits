# frozen_string_literal: true

# Card for an exhibit in grouped search-across results
class ExhibitCardComponent < ViewComponent::Base
  with_collection_parameter :exhibit

  # @param exhibit [Spotlight::Exhibit]
  # @param response [Blacklight::Solr::Response] the search-across response (used for per-exhibit hit counts)
  # @param search_state [Blacklight::SearchState] the current search-across search state
  # @param view_type [Symbol] the current document index view type (e.g. :list or :gallery)
  def initialize(exhibit:, response:, search_state:, view_type:)
    super()
    @exhibit = exhibit
    @response = response
    @search_state = search_state
    @view_type = view_type
  end

  attr_reader :exhibit

  def gallery?
    @view_type == :gallery
  end

  def unpublished?
    !exhibit.published?
  end

  def thumbnail_url
    exhibit.thumbnail.presence&.iiif_url
  end

  def exhibit_path
    helpers.spotlight.exhibit_path(exhibit)
  end

  def results_link
    link_to t('search_across.exhibit.results_count', count: hits),
            helpers.spotlight.search_exhibit_catalog_path(exhibit, exhibit_search_params)
  end

  private

  def hits
    @response.aggregations[SolrDocument.exhibit_slug_field].items.find { |x| x.value == exhibit.slug }.hits
  end

  # Strip out parameters (particularly facets) that don't make sense to pass
  # along to the exhibit-specific search endpoint
  def exhibit_search_params
    params = @search_state.to_h.except(:group, :page, :controller, :action, :search_field)
    exhibit_facet_keys = CatalogController.blacklight_config.facet_fields.keys
    params[:f] &&= params[:f].slice(*exhibit_facet_keys)
    params
  end
end
