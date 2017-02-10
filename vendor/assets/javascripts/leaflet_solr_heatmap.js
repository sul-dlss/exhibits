L.SolrHeatmap = L.GeoJSON.extend({
  options: {
    solrRequestHandler: 'select',
    type: 'geojsonGrid',
    colors: ['#f1eef6', '#d7b5d8', '#df65b0', '#dd1c77', '#980043'],
    maxSampleSize: Number.MAX_SAFE_INTEGER,  // for Jenks classification
    logging: false,
  },

  initialize: function (url, options) {
    var _this = this;
    options = L.setOptions(_this, options);
    _this._solrUrl = url;
    _this._layers = {};
    _this._getData();
  },

  onAdd: function (map) {
    var _this = this;

    // Call the parent function
    L.GeoJSON.prototype.onAdd.call(_this, map);

    map.on('moveend', function () {
      _this._getData();
    });
  },

  _computeHeatmapObject: function (data) {
    var _this = this;
    _this.facetHeatmap = {},
      facetHeatmapArray = data.response.facet_heatmaps[this.options.field];

    // Convert array to an object
    $.each(facetHeatmapArray, function (index, value) {
      if ((index + 1) % 2 !== 0) {
        // Set object keys for even items
        _this.facetHeatmap[value] = '';
      }else {
        // Set object values for odd items
        _this.facetHeatmap[facetHeatmapArray[index - 1]] = value;
      }
    });

    this._computeIntArrays();
  },

  _clearLayers: function () {
    var _this = this;

    switch (_this.options.type) {
      case 'geojsonGrid':
        _this.clearLayers();
        break;
      case 'clusters':
        _this.clusterMarkers.clearLayers();
        break;
      case 'heatmap':
        _this._map.removeLayer(_this.heatmapLayer);
        break;
    }
  },

  _createGeojson: function () {
    var _this = this;
    var geojson = {};

    geojson.type = 'FeatureCollection';
    geojson.features = [];

    $.each(_this.facetHeatmap.counts_ints2D, function (row, value) {
      if (value === null) {
        return;
      }

      $.each(value, function (column, val) {
        if (val === 0) {
          return;
        }

        var newFeature = {
          type: 'Feature',
          geometry: {
            type: 'Polygon',
            coordinates: [
              [
                [_this._minLng(column), _this._minLat(row)],
                [_this._minLng(column), _this._maxLat(row)],
                [_this._maxLng(column), _this._maxLat(row)],
                [_this._maxLng(column), _this._minLat(row)],
                [_this._minLng(column), _this._minLat(row)]
              ]
            ]
          },
          properties: {
            count: val
          }
        };
        geojson.features.push(newFeature);
      });
    });

    _this.addData(geojson);
    var colors = _this.options.colors;
    if (_this.facetHeatmap.counts_ints2D && _this.facetHeatmap.counts_ints2D.length > 0) {
      var classifications = _this._getClassifications(colors.length);
      _this._styleByCount(classifications);
      _this._showRenderTime();
    }
  },

  _createHeatmap: function () {
    var _this = this;
    var heatmapCells = [];
    var cellSize = _this._getCellSize() * .75;
    var colors = _this.options.colors;
    var classifications = _this._getClassifications(colors.length - 1);
    var maxValue = classifications[classifications.length - 1];
    var gradient = _this._getGradient(classifications);

    $.each(_this.facetHeatmap.counts_ints2D, function (row, value) {
      if (value === null) {
        return;
      }

      $.each(value, function (column, val) {
        if (val === 0) {
          return;
        }

        var scaledValue = Math.min((val / maxValue), 1);
        var current = [_this._minLat(row), _this._minLng(column), scaledValue];
        heatmapCells.push(current);

        // need to create options object to set gradient, blu, radius, max
      });
    });

    // settting max due to bug
    // http://stackoverflow.com/questions/26767722/leaflet-heat-issue-with-adding-points-with-intensity
    var options = { max: .0001, radius: cellSize, gradient: gradient };
    var heatmapLayer = L.heatLayer(heatmapCells, options);
    heatmapLayer.addTo(_this._map);
    _this.heatmapLayer = heatmapLayer;
    _this._showRenderTime();
  },

  // heatmap display need hash of scaled counts value, color pairs
  _getGradient: function (classifications) {
    var gradient = {};
    var maxValue = classifications[classifications.length - 1];
    var colors = _this.options.colors; 
    // skip first lower bound, assumed to be 0 from Jenks
    for (var i = 1; i < classifications.length; i++)
  gradient[classifications[i] / maxValue] = colors[i];
    return gradient;
  },

  // compute size of heatmap cells in pixels
  _getCellSize: function () {
    _this = this;
    var mapSize = _this._map.getSize();  // should't we use solr returned map extent?
    var widthInPixels = mapSize.x;
    var heightInPixels = mapSize.y;
    var heatmapRows = _this.facetHeatmap.rows;
    var heatmapColumns = _this.facetHeatmap.columns;
    var sizeX = widthInPixels / heatmapColumns;
    var sizeY = heightInPixels / heatmapRows;
    var size = Math.ceil(Math.max(sizeX, sizeY));
    return size;
  },

  _showRenderTime: function () {
    if (this.options.logging) {
      var _this = this;
      var renderTime = 'Render time: ' + (Date.now() - _this.renderStart) + ' ms';
      console.log(renderTime);
    }
  },

  _createClusters: function() {
    var _this = this;

    _this.clusterMarkers = new L.MarkerClusterGroup({
      maxClusterRadius: 140,
    });

    $.each(_this.facetHeatmap.counts_ints2D, function (row, value) {
      if (value === null) {
        return;
      }

      $.each(value, function (column, val) {
        if (val === 0) {
          return;
        }

        var bounds = new L.latLngBounds([
          [_this._minLat(row), _this._minLng(column)],
          [_this._maxLat(row), _this._maxLng(column)],
        ]);
        _this.clusterMarkers.addLayer(new L.Marker(bounds.getCenter(), {
          count: val,
        }).bindPopup(val.toString()));
      });
    });

    _this._map.addLayer(_this.clusterMarkers);
    _this._showRenderTime();
  },

  _computeIntArrays: function () {
    var _this = this;

    _this.lengthX = (_this.facetHeatmap.maxX - _this.facetHeatmap.minX) / _this.facetHeatmap.columns;
    _this.lengthY = (_this.facetHeatmap.maxY - _this.facetHeatmap.minY) / _this.facetHeatmap.rows;
    _this._clearLayers();
    switch (_this.options.type) {
      case 'geojsonGrid':
        _this._createGeojson();
        break;
      case 'clusters':
        _this._createClusters();
        break;
      case 'heatmap':
        _this._createHeatmap();
        break;
    }
  },

  _getClassifications: function (howMany) {
    var _this = this;
    var oneDArray = [];
    $.each(_this.facetHeatmap.counts_ints2D, function (row, value) {
      if (value != null) {
        oneDArray = oneDArray.concat(value);
      }
    });

    var sampledArray = _this._sampleCounts(oneDArray);

    var series = new geostats(sampledArray);
    var scale = _this.options.colors;
    var classifications = series.getClassJenks(howMany - 1);
    return classifications.reduce(function (previous, current) {
      if (previous.indexOf(current) == -1) {
        previous.push(current);
      }

      return previous;
    }, []);
  },

  _styleByCount: function (classifications) {
    var _this = this;
    var scale = _this.options.colors.slice(this.options.colors.length - classifications.length, this.options.colors.length);

    _this.eachLayer(function (layer) {
      var color;
      $.each(classifications, function (i, val) {
        if (layer.feature.properties.count >= val) {
          color = scale[i];
        }
      });

      layer.setStyle({
        fillColor: color,
        fillOpacity: 0.5,
        weight: 0,
      });
    });
  },

  // Jenks classification can be slow so we optionally sample the data
  // typically any big sample of counts are much the same, don't need to classify on all of them
  _sampleCounts: function (passedArray) {
    _this = this;
    if (passedArray.length <= _this.options.maxSampleSize) {
      return passedArray;   // array too small to sample
    }

    var maxValue = Math.max.apply(Math, passedArray);
    var sampledArray = [];
    var period = Math.ceil(passedArray.length / _this.options.maxSampleSize);
    for (i = 0; i < passedArray.length; i = i + period) {
      sampledArray.push(passedArray[i]);
    }

    sampledArray.push(maxValue);  // make sure largest value gets in, doesn't matter much if duplicated
    return sampledArray;
  },

  _minLng: function (column) {
    return this.facetHeatmap.minX + (this.lengthX * column);
  },

  _minLat: function (row) {
    return this.facetHeatmap.maxY - (this.lengthY * row) - this.lengthY;
  },

  _maxLng: function (column) {
    return this.facetHeatmap.minX + (this.lengthX * column) + this.lengthX;
  },

  _maxLat: function (row) {
    return this.facetHeatmap.maxY - (this.lengthY * row);
  },

  _getData: function () {
    var _this = this;
    var startTime = Date.now();
    $.getJSON({
      url: _this._solrUrl,
      data: {
        bbox: _this._mapViewToBbox(),
      },
      success: function (data) {
        var totalTime = 'Solr response time: ' + (Date.now() - startTime) + ' ms';
        if (_this.options.logging) {
          console.log(totalTime);
        }

        _this.docsCount = data.response.numFound;
        _this.renderStart = Date.now();
        _this._computeHeatmapObject(data);
        _this.fireEvent('dataAdded', data);
      },
    });
  },

  _mapViewToBbox: function () {
    if (this._map === undefined) {
      return '-180,-90,180,90';
    }

    var bounds = this._map.getBounds();
    var wrappedSw = bounds.getSouthWest().wrap();
    var wrappedNe = bounds.getNorthEast().wrap();
    return [wrappedSw.lng, bounds.getSouth(), wrappedNe.lng, bounds.getNorth()].join(',');
  },

  _mapViewToEnvelope: function () {
    if (this._map === undefined) {
      return ':"Intersects(ENVELOPE(-180, 180, 90, -90))"';
    }

    var bounds = this._map.getBounds();
    var wrappedSw = bounds.getSouthWest().wrap();
    var wrappedNe = bounds.getNorthEast().wrap();
    return ':"Intersects(ENVELOPE(' + wrappedSw.lng + ', ' + wrappedNe.lng + ', ' + bounds.getNorth() + ', ' + bounds.getSouth() + '))"';
  },

  _mapViewToWkt: function () {
    if (this._map === undefined) {
      return '["-180 -90" TO "180 90"]';
    }

    var bounds = this._map.getBounds();
    var wrappedSw = bounds.getSouthWest().wrap();
    var wrappedNe = bounds.getNorthEast().wrap();
    return '["' + wrappedSw.lng + ' ' + bounds.getSouth() + '" TO "' + wrappedNe.lng + ' ' + bounds.getNorth() + '"]';
  },

  _solrQuery: function () {
    return '/' + this.options.solrRequestHandler + '?' + this.options.field;
  },
});

L.solrHeatmap = function (url, options) {
  return new L.SolrHeatmap(url, options);
};

// Check if L.MarkerCluster is included
if (typeof L.MarkerCluster !== 'undefined') {
  L.MarkerCluster.prototype.initialize = function (group, zoom, a, b) {

    L.Marker.prototype.initialize.call(this, a ? (a._cLatLng || a.getLatLng()) : new L.LatLng(0, 0), { icon: this });

    this._group = group;
    this._zoom = zoom;

    this._markers = [];
    this._childClusters = [];
    this._childCount = 0;
    this._iconNeedsUpdate = true;

    this._bounds = new L.LatLngBounds();

    if (a) {
      this._addChild(a);
    }

    if (b) {
      this._addChild(b);
      this._childCount = b.options.count;
    }
  };
}
