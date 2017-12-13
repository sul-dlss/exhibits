/* global Blacklight */
/* global Bloodhound */
/* global IndexStatusTypeahead */

(function (global) {
  var IndexStatusTypeahead;

  IndexStatusTypeahead = {
    itemStatusRemoteUrl: null,
    typeaheadRemoteUrl: null,
    typeaheadOptions: { hint: true, highlight: true, minLength: 1 },

    indexStatusTable: function() {
      return $('[data-behavior="index-status-typeahead-table"]');
    },

    init: function (el) {
      var _this = this;
      _this.itemStatusRemoteUrl = el.data().typeaheadRemoteUrl;
      _this.typeaheadRemoteUrl = el.data().typeaheadRemoteUrl + '?q=%QUERY';
      el.typeahead(_this.typeaheadOptions, _this.typeaheadSources());

      el.bind('typeahead:selected', function(e, suggestion) {
        _this.addIndexStatusRow(suggestion);
      });
    },

    typeaheadSources: function() {
      var bloodhound = this.bloodhoundEngine();
      bloodhound.initialize();
      return {
        name: 'druid',
        displayKey: 'druid',
        source: bloodhound.ttAdapter(),
        templates: {
          empty: [
            '<div class="no-items">',
            'No matches found',
            '</div>'
          ].join('\n')
        }
      };
    },

    addIndexStatusRow: function(suggestion) {
      if(this.indexStatusRow(suggestion.druid).length > 0) {
        return; // Return if there is already an index status row present
      }

      this.indexStatusTable().show(); // Ensure the table is shown
      this.indexStatusTable().find('tbody').append(
        [
          '<tr data-index-status-id="' + suggestion.druid + '">',
            '<td>' + suggestion.druid + '</td>',
            '<td data-behavior="index-item-status"></td>',
          '</tr>'
        ].join('\n')
      );

      this.updateItemIndexStatus(suggestion.druid);
    },

    // Getter for an index status row given a druid
    indexStatusRow: function(druid) {
      return $('tr[data-index-status-id="' + druid + '"]');
    },

    updateItemIndexStatus: function(druid) {
      var _this = this;
      $.ajax({ url: _this.itemStatusRemoteUrl + '/' + druid })
       .success(function(data) {
         var row = _this.indexStatusRow(druid);

         if (!data.status.ok) {
           row.addClass('danger');
         }

         var itemStatusCell = row.find('td[data-behavior="index-item-status"]');
         itemStatusCell.text(
           data.status.ok ? 'Published' : data.status.message
         );
      });
    },

    druids: function() {
      return $('[data-index-status-content]').data('index-status-content');
    },

    bloodhoundEngine: function() {
      return new Bloodhound({
        limit: 10,
        remote: {
          url: this.typeaheadRemoteUrl,
          filter: function (druids) {
            return $.map(druids, function (druid) {
              return { druid: druid };
            });
          }
        },
        queryTokenizer: Bloodhound.tokenizers.whitespace,
        datumTokenizer: function(d) {
          return Bloodhound.tokenizers.whitespace(d);
        }
      });
    }
  };

  global.IndexStatusTypeahead = IndexStatusTypeahead;
}(this));

Blacklight.onLoad(function () {
  'use strict';

  $('[data-behavior="index-status-typeahead"]').each(function (i, element) {
    IndexStatusTypeahead.init($(element)); // eslint-disable-line no-undef
  });
});
