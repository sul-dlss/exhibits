/* global Blacklight */
/* global NestedRelatedItems */

(function (global) {
  var NestedRelatedItems;

  NestedRelatedItems = {
    options: { itemSelector: 'li.mods_display_nested_related_item' },
    init: function (el) {
      var _this = this;

      _this.listItems(el).each(function() {
        $(this).removeClass('open');
        _this.addToggleLink($(this));
      });
    },

    listItems: function(list) {
      return list.find(this.options.itemSelector);
    },

    addToggleLink: function(content) {
      var dl = content.find('dl');

      if(dl.length > 0) {
        // Hide and remove the dl (so we can deal with just the text below)
        dl.hide();
        dl.detach();
        // Replace the content of the list item
        // with the current text wrapped in a link
        content.html(this.linkElement(content));
        // Add the dl back in
        content.append(dl);
      }
    },

    linkElement: function(content) {
      var _this = this;
      var link = $('<a href="javascript:;">' + content.text() + '</a>');
      link.on('click', function() {
        _this.toggleMetadata($(this));
      });

      return link;
    },

    toggleMetadata: function(item) {
      var listItem = item.parent('li');
      listItem.toggleClass('open');
      listItem.find('dl').toggle();
    }
  };

  global.NestedRelatedItems = NestedRelatedItems;
}(this));

Blacklight.onLoad(function () {
  'use strict';

  $('.mods_display_nested_related_items').each(function (i, element) {
    NestedRelatedItems.init($(element)); // eslint-disable-line no-undef
  });
});
