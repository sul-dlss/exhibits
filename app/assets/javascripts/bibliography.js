/* eslint-disable camelcase */
/* global Bibliography */

(function (global) {
  var Bibliography;

  Bibliography = {
    options: { toggleThreshold: 5, toggleIndex: 2 },

    init: function (el) {
      var _this = this;
      var $el = $(el);
      var data = $el.data();
      $.getJSON(data.path, {
          'f[related_document_id_ssim][]': data.parentid,
          'f[format_main_ssim][]': 'Reference',
          sort: data.sort,
          format: 'json',
          rows: '1000'
        }, function (response) {
          var docTotal = response.data.length;
          if (docTotal > 0) {
            $el.show();
            var bibliographyList = $el.find('.bibliography-list');

            for (var i = 0; i < docTotal; i++) {
              var bibEntry = response.data[i];
              var html = _this.bibliographyItemTemplate(
                bibEntry, data.path, i, docTotal
              );
              bibliographyList.append(html);
            }

            if (docTotal > _this.options.toggleThreshold) {
              bibliographyList.append(_this.toggleButton());
            }
          }
      });
    },

    bibliographyItemTemplate: function(bibEntry, path, index, total) {
      var elClass = 'bibliography-body';
      var toggleIndex = this.options.toggleIndex;
      var toggleThreshold = this.options.toggleThreshold;

      if (index > toggleIndex && total > toggleThreshold) {
        elClass += ' hide-bibliography';
      }
      var parsedHtml = $.map($.parseHTML($.parseHTML(bibEntry.attributes.formatted_bibliography_ts.attributes.value)[0].textContent), function(value) {
        // If it is HTML, return that, if not just return the text
        if (value.outerHTML) {
          return value.outerHTML;
        }
        return value.textContent;
      });
      return '<p class="' + elClass + '">' +
                parsedHtml +
              ' <a href="' + bibEntry.links.self + '">' +
                '[View full reference]' +
              '</a>' +
             '</p>';
    },

    toggleButton: function() {
      var button = $(
        '<button class="btn btn-secondary bibliography-button">' +
          '<span data-behavior="text">Expand bibliography</span> ' +
          '<span class="bibliography-icon">»</span>' +
        '</button>'
      );

      button.on('click', function() {
        var bibliosToToggle = button.parent().find('.hide-bibliography');
        var hidden = bibliosToToggle.first().is(':hidden');
        bibliosToToggle.toggle();

        if(hidden) {
          button.find('[data-behavior="text"]').text('Collapse bibliography');
          button.addClass('bibliography-expanded');
        } else {
          button.find('[data-behavior="text"]').text('Expand bibliography');
          button.removeClass('bibliography-expanded');
        }
      });

      return button;
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
