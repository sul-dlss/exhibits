// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"

// Required by Blacklight
import * as bootstrap from "bootstrap"
import './blacklight'


import './spotlight'
import githubAutoCompleteElement from "@github/auto-complete-element";

import './bibliography'
import './cited_documents'

import 'blacklight-gallery/blacklight-gallery.esm.js'

import './blacklight_heatmaps'
import './blacklight_oembed'
import './full_text_collapse'
import './index_status_typeahead'
import './exhibit_search_typeahead'
import 'openseadragon-rails'
import './table_of_contents'
import './image_viewer_state_modal'
import './select_image_area'

import BlacklightRangeLimit from "blacklight-range-limit";
BlacklightRangeLimit.init({onLoadHandler: Blacklight.onLoad });
