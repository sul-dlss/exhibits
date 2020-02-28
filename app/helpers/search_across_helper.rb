# frozen_string_literal: true

# Helpers for search across functionality
module SearchAcrossHelper
  def render_search_across_form?
    %w(search_across exhibits).include?(controller_name) && action_name == 'index'
  end

  def search_without_group
    search_state.params_for_search.except(:group)
  end

  def search_with_group
    search_state.params_for_search.merge(group: true)
  end

  def exhibit_metadata
    @exhibit_metadata ||= accessible_exhibits_from_search_results.as_json(
      only: %i(slug title description id published)
    ).index_by { |x| x['slug'] }
  end

  def render_exhibit_title(document:, value:, **)
    exhibit_links = exhibit_metadata.slice(*value).values.map do |x|
      link = link_to(x['title'] || x['slug'], spotlight.exhibit_solr_document_path(x['slug'], document.id))
      badge = content_tag('span', class: 'badge badge-warning ml-1') { t('.unpublished') } unless x['published']

      safe_join([link, badge], ' ')
    end
    safe_join exhibit_links, '<br/>'.html_safe
  end

  def render_exhibit_title_facet(value)
    exhibit_metadata.slice(*value).values.map { |x| x['title'] || x['slug'] }.join(', ')
  end

  private

  def exhibit_slugs
    (
      @response.documents.flat_map { |x| x[SolrDocument.exhibit_slug_field] } |
      (@response.aggregations[SolrDocument.exhibit_slug_field]&.items&.map(&:value) || [])
    ).uniq
  end

  def accessible_exhibits_from_search_results
    Spotlight::Exhibit.where(slug: exhibit_slugs).accessible_by(current_ability)
  end
end
