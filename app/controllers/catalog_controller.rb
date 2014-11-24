# -*- encoding : utf-8 -*-
require 'blacklight/catalog'

class CatalogController < ApplicationController  

  helper Openseadragon::OpenseadragonHelper

  include Blacklight::Catalog
  
  before_filter only: :admin do
    blacklight_config.view.admin_table.thumbnail_field = :thumbnail_square_url_ssm
  end

  before_filter do
    blacklight_config.show.partials.append(:find_this_item)
  end

  configure_blacklight do |config|

    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = { 
      qt: 'search',
      fl: '*'
    }
    
    # solr path which will be added to solr base url before the other solr params.
    #config.solr_path = 'select' 
    
    # items to show per page, each number in the array represent another option to choose from.
    #config.per_page = [10,20,50,100]

    ## Default parameters to send on single-document requests to Solr. These settings are the Blackligt defaults (see SolrHelper#solr_doc_params) or 
    ## parameters included in the Blacklight-jetty document requestHandler.
    #
    #config.default_document_solr_params = {
    #  qt: 'document',
    #  ## These are hard-coded in the blacklight 'document' requestHandler
    #  # fl: '*',
    #  # rows: 1
    #  # q: '{!raw f=id v=$id}' 
    #}

    # solr field configuration for search results/index views
    config.index.title_field = 'full_title_tesim'
    config.index.display_type_field = 'content_metadata_type_ssm'
    config.index.thumbnail_field = :thumbnail_url_ssm
    
    config.show.oembed_field = :oembed_url_ssm
    config.show.partials.insert(1, :oembed)

    config.view.gallery.partials = [:index_header, :index]
    config.view.slideshow.partials = [:index]
    config.view.maps.type = "placename_coord"
    config.view.maps.placename_coord_field = 'placename_coords_ssim'

    # solr field configuration for document/show views
    #config.show.title_field = 'title_display'
    #config.show.display_type_field = 'format'

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
    config.add_facet_field 'genre_ssim', label: 'Genre', limit: true 
    config.add_facet_field 'personal_name_ssm', label: 'Personal Names', limit: true 
    config.add_facet_field 'corporate_name_ssm', label: 'Corporate Names', limit: true
    config.add_facet_field 'subject_geographic_ssim', label: 'Geographic' 
    config.add_facet_field 'subject_temporal_ssim', label: 'Era'  
    config.add_facet_field 'language_ssim', label: 'Language'  
    config.add_facet_field 'type_of_resource_ssim', label: "Type of Resource"

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display 
    config.add_index_field 'id', label: "DRUID", if: :current_user
    config.add_index_field 'identifier_tesim', label: "Identifier"
    config.add_index_field 'language_ssm', label: 'Language'
    config.add_index_field 'abstract_tesim', label: 'Abstract'
    config.add_index_field 'note_mapuse_tesim', label: 'Type'
    config.add_index_field 'note_source_tesim', label: 'Source'
    config.add_index_field 'subject_geographic_tesim', label: 'Geographic Subject'
    config.add_index_field 'subject_temporal_tesim', label: 'Temporal Subject'
    config.add_index_field 'note_LOCAL_NOTES_tesim', label: "Local Notes"
    config.add_index_field 'note_desc_note_tesim', label: "Desc Note"
    config.add_index_field 'note_page_num_tesim', label: "Page Num"
    config.add_index_field 'note_phys_desc_tesim', label: "Physical Description"
    config.add_index_field 'note_provenance_tesim', label: "Provenance"
    config.add_index_field 'note_references_tesim', label: "References"
    config.add_index_field 'origin_date_created_ssm', label: "Date Created"
    config.add_index_field 'origin_place_term_ssm', label: "Place Created"
    config.add_index_field 'personal_name_ssm', label: "Personal Name"
    config.add_index_field 'physical_description_note_color_ssm', label: "Note"
    config.add_index_field 'subject_cartographics_tesim', label: "Cartographics"

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display 
    config.add_show_field 'id', label: "DRUID", if: :current_user
    config.add_show_field 'note_phys_desc_tesim', label: 'Note'
    config.add_show_field 'note_source_tesim', label: 'Source'
    config.add_show_field 'note_desc_note_tesim', label: 'Note'
    config.add_show_field 'note_references_tesim', label: 'References'
    config.add_show_field 'note_provenance_tesim', label: 'Provenance'
    config.add_show_field 'note_page_num_tesim', label: 'Page Number'
    config.add_show_field 'subject_geographic_tesim', label: 'Geographic Subject'
    config.add_show_field 'subject_temporal_tesim', label: 'Temporal Subject'
    config.add_show_field 'personal_name_ssm', label: 'Personal Names'
    config.add_show_field 'corporate_name_ssm', label: 'Corporate Names'

    config.add_sort_field 'score desc, sort_title_ssi asc', label: 'Relevance' 
    config.add_sort_field 'sort_title_ssi asc', label: 'Title' 
    config.add_sort_field 'sort_type_ssi asc', label: 'Type' 
    config.add_sort_field 'sort_date_dtsi asc', label: 'Date' 
    config.add_sort_field 'sort_source_ssi asc', label: 'Source' 
    config.add_sort_field 'id asc', label: 'Identifier' 
  end



end 
