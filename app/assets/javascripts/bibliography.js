/* eslint-disable camelcase */
/* global Bibliography */

(function (global) {
  var Bibliography;

  Bibliography = {
    init: function (el) {
      var $el = $(el);
      var data = $el.data();
      $.getJSON(data.path, {
          'f[related_document_id_ssim][]': data.parentid,
          'f[format_main_ssim][]': 'Reference',
          sort: data.sort,
          format: 'json',
          rows: '1000'
        }, function (response) {
          if (response.response.docs.length > 0) {
            $el.show();

            for (var i = 0; i < response.response.docs.length; i++) {
              var bibEntry = response.response.docs[i];
              var html = '<p class="bibliography-body">' +
                          bibEntry.formatted_bibliography_ts +
                          ' <a href="' +
                          [ data.path, bibEntry.id].join('/') +
                          '">[View full reference]</a>' +
                          '</p>';
              $el.find('.bibliography-list').append(html);
            }
          }
      });
    }
  };

  global.Bibliography = Bibliography;
}(this));

Blacklight.onLoad(function () {
  'use strict';

  $('[data-behavior="bibliography-contents"]').each(function (i, element) {
    Bibliography.init(element); // eslint-disable-line no-undef
  });
});
