import 'leaflet'
import 'leaflet-iiif'
import 'leaflet-editable'
import 'leaflet.path.drag'

import Spotlight from "spotlight-frontend/app/assets/javascripts/spotlight/spotlight.esm.js";

// Set the image path prefix for Leaflet icons
L.Icon.Default.prototype.options.imagePath = "https://unpkg.com/leaflet@1.9.4/dist/images/"

Blacklight.onLoad(function() {
  Spotlight.activate();
});

import './sir_trevor_block_overrides'
