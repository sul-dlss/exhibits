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

  # Overrides

  def show_pagination?(*_args)
    return false if render_grouped_response?

    @response.limit_value.positive?
  end

  def document_index_path_templates
    return ['exhibit_%<index_view_type>s'] if render_grouped_response?

    [
      'document_%<index_view_type>s',
      'catalog/document_%<index_view_type>s',
      'catalog/document_list'
    ].compact
  end

  def render_grouped_document_index(response = @response)
    slugs = response.aggregations[SolrDocument.exhibit_slug_field].items.map(&:value)
    exhibits = Spotlight::Exhibit.where(slug: slugs).sort_by { |e| slugs.index e.slug }
    render_document_index(exhibits)
  end

  def opensearch_catalog_url(*args)
    spotlight.opensearch_search_across_url(*args)
  end

  def link_to_document(doc, field_or_opts, opts = { counter: nil })
    label = case field_or_opts
            when NilClass
              index_presenter(doc).heading
            when Hash
              opts = field_or_opts
              index_presenter(doc).heading
            when Proc, Symbol
              Deprecation.silence(Blacklight::IndexPresenter) do
                index_presenter(doc).label field_or_opts, opts
              end
            else # String
              field_or_opts
            end

    if doc[SolrDocument.exhibit_slug_field]&.many?
      label
    else
      link_to label, url_for_document(doc), send(:document_link_params, doc, opts)
    end
  end

  def exhibit_metadata
    @exhibit_metadata ||= accessible_exhibits_from_search_results.as_json(only: %i(slug title description id))
                                                                 .index_by { |x| x['slug'] }
  end

  def render_exhibit_title(document:, value:, **)
    exhibit_links = exhibit_metadata.slice(*value).values.map do |x|
      link_to x['title'] || x['slug'], spotlight.exhibit_solr_document_path(x['slug'], document.id)
    end
    safe_join exhibit_links, '<br/>'.html_safe
  end

  def render_exhibit_title_facet(value)
    exhibit_metadata.slice(*value).values.map { |x| x['title'] || x['slug'] }.join(', ')
  end

  ##
  # Override the Kaminari page_entries_info helper with our own, blacklight-aware
  # implementation. Why do we have to do this?
  #  - We need custom counting information for grouped results
  #  - We need to provide number_with_delimiter strings to i18n keys
  # If we didn't have to do either one of these, we could get away with removing
  # this entirely.
  #
  # @param [RSolr::Resource] collection (or other Kaminari-compatible objects)
  # @return [String]
  def page_entries_info(collection, entry_name: nil)
    entry_name = if entry_name
                   entry_name.pluralize(collection.size, I18n.locale)
                 else
                   collection.entry_name(count: collection.size).to_s.downcase
                 end

    entry_name = entry_name.pluralize unless collection.total_count == 1

    # grouped response objects need special handling
    end_num = if collection.respond_to?(:groups) && render_grouped_response?(collection)
                collection.groups.length
              else
                collection.limit_value
              end

    end_num = if collection.offset_value + end_num <= collection.total_count
                collection.offset_value + end_num
              else
                collection.total_count
              end

    case collection.total_count
      when 0
        t('search_across.pagination_info.no_items_found', entry_name: entry_name).html_safe
      when 1
        t('search_across.pagination_info.single_item_found', entry_name: entry_name).html_safe
      else
        t('search_across.pagination_info.pages', entry_name: entry_name,
                                                     current_page: collection.current_page,
                                                     num_pages: collection.total_pages,
                                                     start_num: number_with_delimiter(collection.offset_value + 1),
                                                     end_num: number_with_delimiter(end_num),
                                                     total_num: number_with_delimiter(collection.total_count),
                                                     count: collection.total_pages).html_safe
    end
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
