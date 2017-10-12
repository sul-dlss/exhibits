##
# Blacklight controller providing search and discovery features
class CatalogController < ApplicationController
  include BlacklightAdvancedSearch::Controller
  helper Openseadragon::OpenseadragonHelper

  include Blacklight::Catalog

  before_action only: :admin do
    blacklight_config.view.admin_table.thumbnail_field = :thumbnail_square_url_ssm
  end

  configure_blacklight do |config|
    # default advanced config values
    config.advanced_search ||= Blacklight::OpenStructWithHashAccess.new
    # config.advanced_search[:qt] ||= 'advanced'
    config.advanced_search[:url_key] ||= 'advanced'
    config.advanced_search[:query_parser] ||= 'dismax'
    config.advanced_search[:form_solr_parameters] ||= {}

    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = {
      qt: 'search',
      fl: '*'
    }

    config.default_autocomplete_solr_params = {
      qf: 'id^1000 title_245_unstem_search^200 title_245_search^100 id_ng^50 full_title_ng^50 all_search'
    }

    config.index.document_actions[:bookmark].if = false
    config.show.document_actions[:bookmark].if = false

    # solr path which will be added to solr base url before the other solr params.
    # config.solr_path = 'select'

    # items to show per page, each number in the array represent another option to choose from.
    # config.per_page = [10,20,50,100]

    ## Default parameters to send on single-document requests to Solr. These settings are
    # the Blacklight defaults (see SolrHelper#solr_doc_params) or
    # parameters included in the Blacklight-jetty document requestHandler.
    #
    # config.default_document_solr_params = {
    #  qt: 'document',
    #  ## These are hard-coded in the blacklight 'document' requestHandler
    #  # fl: '*',
    #  # rows: 1
    #  # q: '{!raw f=id v=$id}'
    # }

    # solr field configuration for search results/index views
    config.index.title_field = 'title_display'
    config.index.display_type_field = 'display_type'
    config.index.default_bibliography_thumbnail = 'default-square-thumbnail-book.png'
    config.index.thumbnail_field = :thumbnail_url_ssm
    config.index.square_image_field = :thumbnail_square_url_ssm
    config.index.slideshow_field = :large_image_url_ssm

    config.show.title_field = 'title_full_display'
    config.show.oembed_field = :url_fulltext
    config.show.tile_source_field = :content_metadata_image_iiif_info_ssm

    config.show.partials.insert(1, :viewer)
    config.show.partials.unshift :bibliography_buttons
    config.show.partials << :bibliography

    config.view.list.thumbnail_field = :thumbnail_square_url_ssm
    config.view.list.partials = [:thumbnail, :index_header, :index]
    config.view.gallery.partials = [:index_header, :index]
    config.view.gallery.default_bibliography_thumbnail = 'default-square-thumbnail-book-large.png'
    config.view.heatmaps.partials = []
    config.view.heatmaps.color_ramp = ['#ffffcc', '#a1dab4', '#41b6c4', '#2c7fb8', '#253494']
    config.view.masonry.partials = [:index]
    config.view.masonry.default_bibliography_thumbnail = 'default-square-thumbnail-book-large.png'
    config.view.slideshow.partials = [:index]
    config.view.embed.partials = [:viewer]
    config.view.embed.if = false

    # BlacklightHeatmaps configuration values
    config.geometry_field = :geographic_srpt
    # Basemaps configured include: 'positron', 'darkMatter', 'OpenStreetMap.HOT'
    config.basemap_provider = 'positron'

    # solr field configuration for document/show views
    # config.show.title_field = 'title_display'
    # config.show.display_type_field = 'format'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    #
    # :show may be set to false if you don't want the facet to be drawn in the
    # facet bar
    config.add_facet_field 'format_main_ssim', label: 'Resource type', limit: true
    config.add_facet_field 'pub_year_w_approx_isi', label: 'Date', limit: true
    config.add_facet_field 'pub_year_no_approx_isi', label: 'Date (no approx)', limit: true
    config.add_facet_field 'language', label: 'Language', limit: true
    config.add_facet_field 'author_person_facet', label: 'Author', limit: true # includes Collectors
    config.add_facet_field 'author_no_collector_ssim', label: 'Author (no Collectors)', limit: true
    config.add_facet_field 'collector_ssim', label: 'Collector', limit: true
    config.add_facet_field 'topic_facet', label: 'Topic', limit: true
    config.add_facet_field 'geographic_facet', label: 'Region', limit: true
    config.add_facet_field 'era_facet', label: 'Era', limit: true
    config.add_facet_field 'author_other_facet', label: 'Organization (as author)', limit: true
    config.add_facet_field 'genre_ssim', label: 'Genre', limit: true
    config.add_facet_field 'series_ssi', label: 'Series', limit: true
    config.add_facet_field 'box_ssi', label: 'Box', limit: true
    config.add_facet_field 'folder_ssi', label: 'Folder', limit: true
    # The Donor tags, Folder Name and Document subtype facets below were added as a specific need of the Feigenbaum
    #   exhibit.  Indexing of these fields were also added to spotlight-dor-resources.  The facets should be hidden
    #   for all other exhibits that do no have any data in this field.  Possible later refactoring could separate
    #   fields/facets that are exhibit specific.  It is also in the _index_field list below for display purposes.
    config.add_facet_field 'folder_name_ssi', label: 'Folder Name', limit: true
    config.add_facet_field 'donor_tags_ssim', label: 'Donor tags', limit: true
    config.add_facet_field 'doc_subtype_ssi', label: 'Document Subtype', limit: true
    config.add_facet_field 'collection_with_title', label: 'Collection', limit: true, helper_method: :collection_title

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # Solr fields to be displayed in the search results and the show (single result) views
    #   The ordering of the field names is the order of the display

    # The inline map should only be displayed on the catalog#show page.
    config.add_index_field config.geometry_field, label: 'Inline Map',
                                                  helper_method: :document_leaflet_map,
                                                  immutable: config.view.keys.map { |k| [k, false] }.to_h

    config.add_index_field 'title_full_display', label: 'Title'
    config.add_index_field 'title_variant_display', label: 'Alternate Title'
    config.add_index_field 'author_person_full_display', label: 'Author' # includes Collectors
    config.add_index_field 'author_no_collector_ssim', label: 'Author (no Collectors)'
    config.add_index_field 'editor_ssim', label: 'Editor'
    config.add_index_field 'collector_ssim', label: 'Collector'
    config.add_index_field 'author_corp_display', label: 'Corporate Author'
    config.add_index_field 'author_meeting_display', label: 'Meeting Author'
    config.add_index_field 'summary_display', label: 'Description'
    config.add_index_field 'topic_display', label: 'Topic'
    config.add_index_field 'subject_other_display', label: 'Subject'
    config.add_index_field 'language', label: 'Language'
    config.add_index_field 'physical', label: 'Physical Description'
    config.add_index_field 'pub_display', label: 'Publication Info'
    config.add_index_field 'pub_year_w_approx_isi', label: 'Date'
    config.add_index_field 'pub_year_no_approx_isi', label: 'Date (no approx)'
    config.add_index_field 'imprint_display', label: 'Imprint'
    config.add_index_field 'genre_ssim', label: 'Genre'
    config.add_index_field 'series_ssi', label: 'Series'
    config.add_index_field 'box_ssi', label: 'Box'
    config.add_index_field 'folder_ssi', label: 'Folder'
    config.add_index_field 'folder_name_ssi', label: 'Folder Name'
    config.add_index_field 'identifier_ssim', label: 'Identifier'
    config.add_index_field 'location_ssi', label: 'Location'
    config.add_index_field 'donor_tags_ssim', label: 'Donor tags'
    config.add_index_field 'doc_subtype_ssi', label: 'Document Subtype'
    # Fields added by Zotero API BibTeX import
    config.add_index_field 'volume_ssm', label: 'Volume'
    config.add_index_field 'pages_ssm', label: 'Pages'
    config.add_index_field 'doi_ssim', label: 'DOI'
    config.add_index_field 'issue_ssm', label: 'Issue'
    config.add_index_field 'edition_ssm', label: 'Edition'
    config.add_index_field 'university_ssim', label: 'University'
    config.add_index_field 'thesis_type_ssm', label: 'Degree Type'
    config.add_index_field 'book_title_ssim', label: 'Book Title'
    config.add_index_field 'ref_type_ssm', label: 'Reference Type'
    # This was added for the Feigbenbaum exhibit.  It includes any general <note> from
    #  the MODs that do not have attributes.  It is used for display and is not facetable.
    config.add_index_field 'general_notes_ssim', label: 'Notes'
    config.add_index_field 'collection_with_title', label: 'Collection', helper_method: :document_collection_title
    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.

    config.add_search_field('search') do |field|
      field.label = 'Everything'
      field.solr_local_parameters = {
        pf2: '$p2',
        pf3: '$pf3'
      }
    end

    config.add_search_field('search_title') do |field|
      field.label = 'Title'
      field.solr_local_parameters = {
        qf: '$qf_title',
        pf: '$pf_title',
        pf3: '$pf3_title',
        pf2: '$pf2_title'
      }
    end

    config.add_search_field('search_author') do |field|
      field.label = 'Author/Contributor'
      field.solr_local_parameters = {
        qf: '$qf_author',
        pf: '$pf_author',
        pf3: '$pf3_author',
        pf2: '$pf2_author'
      }
    end

    config.add_search_field('subject_terms') do |field|
      field.label = 'Subject'
      field.solr_local_parameters = {
        qf: '$qf_subject',
        pf: '$pf_subject',
        pf3: '$pf3_subject',
        pf2: '$pf2_subject'
      }
    end

    config.add_search_field('call_number') do |field|
      field.label = 'Call number'
      field.include_in_advanced_search = false
      field.solr_parameters = { defType: 'lucene' }
      field.solr_local_parameters = {
        df: 'callnum_search'
      }
    end

    config.add_search_field('full_text') do |field|
      field.label = 'Full text'
      field.include_in_advanced_search = false
      field.solr_local_parameters = {
        qf: '$qf_full_text',
        pf: '$pf_full_text',
        pf3: '$pf3_full_text',
        pf2: '$pf2_full_text'
      }
    end
    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'score desc, pub_year_isi desc, title_sort asc', label: 'relevance'
    config.add_sort_field 'pub_year_isi desc, title_sort asc', label: 'year (new to old)'
    config.add_sort_field 'pub_year_isi asc, title_sort asc', label: 'year (old to new)'
    config.add_sort_field 'author_sort asc, title_sort asc', label: 'author'
    config.add_sort_field 'title_sort asc, pub_year_isi desc', label: 'title'
  end

  # JSON API queries should not trigger new search histories
  def start_new_search_session?
    super && params[:format] != 'json'
  end
end
