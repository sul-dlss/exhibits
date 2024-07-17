/* global Blacklight */
/* global Bloodhound */
/* global ExhibitSearchTypeahead */

(function (global) {
  var ExhibitSearchTypeahead;

  ExhibitSearchTypeahead = {
    form: null,
    typeaheadElement: null,
    typeaheadRemoteUrl: null,
    typeaheadOptions: { hint: true, highlight: true, minLength: 1 },

    init: function (el) {
      var _this = this;
      var container = el.parents('.exhibit-search-typeahead');
      _this.typeaheadElement = el;
      _this.form = el.parents('form');
      _this.typeaheadRemoteUrl = el.data().typeaheadRemoteUrl + '?q=%QUERY';
      _this.preventFormSubmitOnTypeahead();

      // Cleanup typeahead if it alread exists (e.g. back-button cache)
      if (el.parent().hasClass('twitter-typeahead')) {
        el.typeahead('destroy');

        el.attr('disabled', false);
        el.attr('style', '');
        el.removeClass('tt-hint');

        container.html(el);
      }

      el.typeahead(_this.typeaheadOptions, _this.typeaheadSources());

      container.find('.tt-dropdown-menu').attr('aria-live', 'assertive');

      el.bind('typeahead:selected', function(e, suggestion) {
        window.location = '/' + suggestion.slug;
      });
    },

    preventFormSubmitOnTypeahead: function() {
      var _this = this;

      _this.form.on('submit', function(e) {
        if(_this.typeaheadElement.is(':focus')) {
          e.preventDefault();
        }
      });
    },

    typeaheadSources: function() {
      var bloodhound = this.bloodhoundEngine();
      bloodhound.initialize();
      return {
        name: 'exhibit',
        displayKey: 'title',
        source: bloodhound.ttAdapter(),
        templates: {
          empty: [
            '<div class="no-items">',
            'No matches found',
            '</div>'
          ].join('\n'),
          suggestion: function(suggestion) {
            return `<div class="exhibit-result">${suggestion.title} <span class="subtitle">${suggestion.subtitle ?? "" }</span></div>`;
          }
        }
      };
    },

    bloodhoundEngine: function() {
      return new Bloodhound({
        limit: 5,
        remote: {
          url: this.typeaheadRemoteUrl,
          filter: function (documents) {
            return $.map(documents, function (document) {
              return {
                title: document.title,
                subtitle: document.subtitle,
                slug: document.slug
              };
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

  global.ExhibitSearchTypeahead = ExhibitSearchTypeahead;
}(this));

Blacklight.onLoad(function () {
  'use strict';

  $('[data-behavior="exhibit-search-typeahead"]').each(function (i, element) {
    ExhibitSearchTypeahead.init($(element)); // eslint-disable-line no-undef
  });
});
