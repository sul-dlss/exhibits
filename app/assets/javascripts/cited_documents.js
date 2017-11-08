/* eslint-disable camelcase */
/* global CitedDocuments */
/* global Blacklight */

(function (global) {
  var CitedDocuments;

  CitedDocuments = {
    init: function (el) {
      var $el = $(el);
      var data = $el.data();
      var solrQueryString = data.documentids.join(' OR ');

      $.getJSON(data.path, {
        q: solrQueryString,
        format: 'json',
        rows: 1000
      }, function (response) {
        response.response.docs.forEach(function(citedDocEntry) {
          var html = '<li class="cited-documents-body">' +
                ' <a href="' + citedDocEntry.id + '">' +
                citedDocEntry.title_full_display +
                '</a>' +
                '</li>';
          $el.find('.cited-documents-list').append(html);
        });
      });
    }
  };

  global.CitedDocuments = CitedDocuments;
}(this));

Blacklight.onLoad(function () {
  'use strict';

  $('[data-behavior="cited-documents-contents"]').each(function (i, element) {
    CitedDocuments.init(element); // eslint-disable-line no-undef
  });
});
