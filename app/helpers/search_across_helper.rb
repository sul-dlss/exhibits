# frozen_string_literal: true

# Helpers for search across functionality
module SearchAcrossHelper
  def render_search_across_form?
    %w(search_across exhibits).include?(controller_name) && action_name == 'index'
  end

  # Overrides

  def show_pagination?(*_args)
    return false if render_grouped_response?

    @response.limit_value.positive?
  end

  def document_index_path_templates
    [
      ('exhibit_%<index_view_type>s' if render_grouped_response?),
      'document_%<index_view_type>s',
      'catalog/document_%<index_view_type>s',
      'catalog/document_list'
    ].compact
  end

  def render_grouped_document_index
    slugs = @response.aggregations[SolrDocument.exhibit_slug_field].items.map(&:value)
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

    if doc[SolrDocument.exhibit_slug_field].many?
      label
    else
      link_to label, url_for_document(doc), send(:document_link_params, doc, opts)
    end
  end

  def exhibit_slugs
    @response.documents.flat_map { |x| x[SolrDocument.exhibit_slug_field] }.uniq
  end

  def accessible_exhibits_from_search_results
    Spotlight::Exhibit.where(slug: exhibit_slugs).accessible_by(current_ability)
  end

  def exhibit_metadata
    @exhibit_metadata ||= accessible_exhibits_from_search_results.as_json(only: %i(slug title description id))
                                                                 .index_by { |x| x['slug'] }
  end

  def render_exhibit_title(document:, value:, **)
    exhibit_links = exhibit_metadata.slice(*value).values.map do |x|
      link_to x['title'] || x['slug'], spotlight.exhibit_solr_document_path(x['slug'], document.id)
    end

    safe_join exhibit_links, ', '
  end

  def render_exhibit_title_facet(value)
    exhibit_metadata.slice(*value).values.map { |x| x['title'] || x['slug'] }.join(', ')
  end
end
