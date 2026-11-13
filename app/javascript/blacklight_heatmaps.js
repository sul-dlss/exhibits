import 'leaflet-sidebar/src/L.Control.Sidebar'
import BlacklightHeatmaps from 'blacklight-heatmaps/app/assets/javascripts/blacklight_heatmaps/default.esm.js'
window.BlacklightHeatmaps = BlacklightHeatmaps

// Solr returns `counts_ints2D: null` when no documents in the search have geometry
// within the requested bbox. The upstream layer iterates over it unconditionally,
// so normalize it to an empty grid to render an empty map instead of throwing.
// TODO: Remove this override once https://github.com/sul-dlss/blacklight_heatmaps/pull/108
// is released and the blacklight-heatmaps package is upgraded (keep spec/features/heatmaps_spec.rb).
const computeHeatmapObject = L.SolrHeatmap.prototype._computeHeatmapObject
L.SolrHeatmap.prototype._computeHeatmapObject = function (data) {
  const facetHeatmap = data?.response?.facet_heatmaps?.[this.options.field]
  if (facetHeatmap && !facetHeatmap.counts_ints2D) facetHeatmap.counts_ints2D = []

  return computeHeatmapObject.call(this, data)
}

Blacklight.onLoad(function () {
  BlacklightHeatmaps.init()
})

// Override the leaflet sidebar to update our own documents container that appears below the map.
L.Control.ExhibitsSidebar = L.Control.Sidebar.extend({
  show: function() {
  },

  setContent: function(content) {
    document.getElementById("heatmaps-documents-list").innerHTML = content;
  }
});

L.control.sidebar = function(id, options) {
  return new L.Control.ExhibitsSidebar(id, options);
};

// CARTO basemaps require an API key; it's set by Settings.carto_basemaps_key in the layout.
const cartoBasemapsKey = document.querySelector('meta[name="carto-basemaps-key"]')?.content

BlacklightHeatmaps.Basemaps.positron = L.tileLayer(
  `https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png?key=${cartoBasemapsKey}`, {
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, &copy; <a href="https://carto.com/attributions">CARTO</a>',
    detectRetina: true,
    noWrap: true,
  }
);
