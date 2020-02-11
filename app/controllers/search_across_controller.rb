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
    config.index.document_presenter_clas = SearchAcrossIndexPresenter
    config.search_builder_class = SearchAcrossSearchBuilder
    config.track_search_session = false
    config.default_solr_params["f.#{SolrDocument.exhibit_slug_field}.facet.limit"] = -1
    config.index_fields.clear
    config.add_index_field SolrDocument.exhibit_slug_field, helper_method: :render_exhibit_title
    config.add_index_field 'author_person_full_display', label: 'Author'
    config.add_index_field 'subject_other_display', label: 'Subject'

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

    config.search_fields['search'].label = :'search_across.fields.search.search'
  end

  before_action do
    add_facet_visibility_field

    tags = Spotlight::Exhibit.accessible_by(current_ability).tag_counts_on(:tags).pluck(:name)
    blacklight_config.add_facet_field 'exhibit_tags', query: (tags.each_with_object({}) do |v, h|
      slugs = Spotlight::Exhibit.accessible_by(current_ability).tagged_with(v).pluck(:slug)

      h[v] = {
        label: v,
        fq: "#{SolrDocument.exhibit_slug_field}:(#{slugs.join(' OR ')})"
      }
    end)

    if render_grouped_response?
      blacklight_config.index.collection_actions.delete(:per_page_widget)

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

  helper_method :render_grouped_response?, :url_for_document

  def render_grouped_response?(*_args)
    params[:group]
  end

  # TODO
  def url_for_document(doc)
    if doc[SolrDocument.exhibit_slug_field].many?
      '#'
    else
      exhibit_id = doc.first(SolrDocument.exhibit_slug_field)
      spotlight.exhibit_solr_document_path(exhibit_id, doc.id)
    end
  end
end
