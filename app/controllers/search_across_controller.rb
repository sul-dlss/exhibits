# frozen_string_literal: true

##
# Spotlight's catalog controller. Note that this subclasses
# the host application's CatalogController to get its configuration,
# partial overrides, etc
class SearchAcrossController < ::CatalogController
  include Blacklight::Catalog
  include Spotlight::Catalog

  helper Spotlight::CrudLinkHelpers
  include BlacklightRangeLimit::ControllerOverride

  layout 'spotlight/home'

  def blacklight_config
    @blacklight_config ||= self.class.blacklight_config.deep_copy
  end

  skip_before_action :set_current_search_session

  before_action do
    search_session['id'] = nil
  end

  configure_blacklight do |config|
    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params.reject! { |k, _v| k.to_s.starts_with? 'hl' }

    config.index.document_presenter_class = SearchAcrossIndexPresenter
    config.search_builder_class = SearchAcrossSearchBuilder
    config.track_search_session = false
    config.default_solr_params["f.#{SolrDocument.exhibit_slug_field}.facet.limit"] = -1
    config.index_fields.clear
    list_view_only = ->(context, *) { context.view_context.document_index_view_type == :list }
    config.add_index_field SolrDocument.exhibit_slug_field, helper_method: :render_exhibit_title
    config.add_index_field 'subject_other_display', label: 'Subject', if: list_view_only
    config.add_index_field 'author_person_full_display', label: 'Author', if: list_view_only

    config.facet_fields.clear
    config.add_facet_field SolrDocument.exhibit_slug_field,
                           helper_method: :render_exhibit_title_facet
    config.add_facet_field 'pub_year_tisim', label: 'Date Range',
                                             range: true,
                                             partial: 'blacklight_range_limit/range_limit_panel'

    config.add_facet_fields_to_solr_request!

    previous_actions = config.index.collection_actions.to_h.dup
    config.index.collection_actions.clear

    config.add_results_collection_tool('group_toggle')
    config.index.collection_actions = blacklight_config.index.collection_actions.merge(previous_actions)

    previous_views = config.view.dup

    config.view.clear
    config.view.list = previous_views.list
    config.view.gallery = previous_views.gallery

    config.search_fields.clear
    config.add_search_field('default')
  end

  before_action do
    blacklight_config.add_facet_field 'exhibit_tags', query: exhibit_tags_facet_query_config

    if can? :curate, Spotlight::Exhibit
      blacklight_config.add_facet_field 'exhibit_visibility',
                                        label: I18n.t(:'spotlight.catalog.facets.exhibit_visibility.label'),
                                        query: exhibit_visibility_query_config
    end

    if render_grouped_response?
      # we can't use solr's pagination because it can't sort  by exhibit title
      blacklight_config.index.collection_actions.delete(:per_page_widget)

      # define some stub sort fields (picked up and handled in solr for count (below) and in the  UI for index)
      blacklight_config.sort_fields.clear
      blacklight_config.add_sort_field(key: 'index', sort: '')
      blacklight_config.add_sort_field(key: 'count', sort: '')

      blacklight_config.facet_fields[SolrDocument.exhibit_slug_field].sort = if params[:sort] == 'index'
                                                                               'index'
                                                                             else
                                                                               'count'
                                                                             end
    end
  end

  before_action only: [:index] do
    add_breadcrumb t(:'root.breadcrumb'), root_url
    add_breadcrumb t(:'spotlight.catalog.breadcrumb.index'), search_search_across_path(search_state.params_for_search)
  end

  helper_method :render_grouped_response?, :url_for_document

  def render_grouped_response?(*_args)
    params[:group]
  end

  def url_for_document(doc)
    if doc[SolrDocument.exhibit_slug_field].many?
      '#'
    else
      exhibit_id = doc.first(SolrDocument.exhibit_slug_field)
      spotlight.exhibit_solr_document_path(exhibit_id, doc.id)
    end
  end

  # Generate facet queries for exhibit tags
  def exhibit_tags_facet_query_config
    tags = Spotlight::Exhibit.accessible_by(current_ability).tag_counts_on(:tags).pluck(:name)

    (tags.each_with_object({}) do |v, h|
      slugs = Spotlight::Exhibit.accessible_by(current_ability).tagged_with(v).pluck(:slug)

      h[v] = {
        label: v,
        fq: "#{SolrDocument.exhibit_slug_field}:(#{slugs.join(' OR ')})"
      }
    end)
  end

  def exhibit_visibility_query_config
    exhibits = Spotlight::Exhibit.accessible_by(current_ability, :curate)
    fqs = exhibits.map do |e|
      "#{blacklight_config.document_model.visibility_field(e)}:false"
    end

    {
      private: {
        label: I18n.t(:'spotlight.catalog.facets.exhibit_visibility.private'),
        fq: fqs.join(' OR ')
      }
    }
  end
end
