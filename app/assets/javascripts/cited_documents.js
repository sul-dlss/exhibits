/* eslint-disable camelcase */
/* global CitedDocuments */
/* global Blacklight */

(function (global) {
  var CitedDocuments;

  CitedDocuments = {
    init: function (el) {
      var $el = $(el);
      const citedDocList = $el.find('.cited-documents-list');
      // Prevent repeat script run on page back
      if (citedDocList[0].innerHTML != '') return;

      var data = $el.data();
      var solrQueryString = data.documentids.join(' OR ');

      $.post(data.path, {
        q: solrQueryString,
        format: 'json',
        rows: 1000
      }, function (response) {
        response.data.forEach(function(citedDocEntry) {
          var html = '<li class="cited-documents-body">' +
                ' <a href="' + citedDocEntry.links.self + '">' +
                citedDocEntry.attributes.title_full_display.attributes.value +
                '</a>' +
                '</li>';
          citedDocList.append(html);
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
