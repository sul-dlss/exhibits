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

  def in_search_across?
    controller.controller_name == 'search_across'
  end

  # Strip out parameters (particularly facets) that don't make sense to pass
  # along to the exhibit-specific search endpoint
  def exhibit_search_state_params(my_search_state = search_state)
    exhibit_search_state_params = my_search_state.to_h.except(:group, :page, :controller, :action, :search_field)
    exhibit_facet_keys = CatalogController.blacklight_config.facet_fields.keys
    exhibit_search_state_params[:f] &&= exhibit_search_state_params[:f].slice(*exhibit_facet_keys)
    exhibit_search_state_params
  end

  def unpublished_badge(**html_options)
    css_class = html_options.delete(:class)
    content_tag('span', class: "badge badge-warning #{css_class}", **html_options) { t('catalog.index.unpublished') }
  end

  def exhibit_metadata
    @exhibit_metadata ||= begin
      attrs = %i(slug title description id published)
      arel_attrs = attrs.collect { |attr| Arel.sql(attr.to_s) } # Needed for rails 6
      data = accessible_exhibits_from_search_results.pluck(*arel_attrs).map do |exhibit|
        attrs.zip(exhibit).to_h.stringify_keys
      end
      data.index_by { |x| x['slug'] }
    end
  end

  def render_exhibit_title(document:, value:, **)
    exhibit_links = exhibit_metadata.slice(*value).values.map do |x|
      link = link_to(x['title'] || x['slug'], spotlight.exhibit_solr_document_path(x['slug'], document.id))
      badge = unpublished_badge(class: 'ml-1') unless x['published']

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
