// Entry point for the build script in your package.json

//= require rails-ujs
//= require turbolinks
//
// Required by Blacklight
import './blacklight'
import './sir_trevor'

import "spotlight-frontend/app/assets/javascripts/spotlight/spotlight.esm.js";
import githubAutoCompleteElement from "@github/auto-complete-element";

import './bibliography'
import './cited_documents'
import 'blacklight-gallery/vendor/assets/javascripts/imagesloaded.pkgd.js'
import 'blacklight-gallery/app/assets/javascripts/blacklight_gallery/slideshow'
import 'blacklight-gallery/app/assets/javascripts/blacklight_gallery/masonry'

import './blacklight_heatmaps'


import 'blacklight-oembed'
import './full_text_collapse'
import './index_status_typeahead'
import './exhibit_search_typeahead'
import './nested_related_items'
import 'openseadragon-rails'
import './table_of_contents'
import './site_search_type_toggle'
