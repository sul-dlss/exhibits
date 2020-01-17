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

      _this.addToggleAll(el);
      _this.toggleAll(el);
    },

    listItems: function(list) {
      return list.find(this.options.itemSelector);
    },

    addToggleAll: function(content) {
      // find the preceding <dt>
      var title = $(content).parents('dd').prev();
      title.append('<a href="javascript:;" id="toggleAll" class="mods_display_related_item_label">Expand all</a>');
      title.attr('id', 'mods_display_related_item_dt');
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

    toggleAll: function(content) {
      var _this = this;
      $('#toggleAll').on('click', function(){
        var toggleLink  = $(this);
        toggleLink.toggleClass('open');
        toggleLink.text((toggleLink.text() == 'Collapse all') ? 'Expand all' : 'Collapse all');
        var links =  _this.listItems(content);

        // Handle mixed lists of open / closed items
        if (toggleLink.hasClass('open')){
          links = links.not('.open').find('a');
        } else {
          links = links.filter($('.open')).find('a');
        }
        links.each(function(){
          _this.toggleMetadata($(this));
        });
      });
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

  // Load JS in Bootstrap modal
  $('#blacklight-modal').on('shown.bs.modal', function () {
    $('.mods_display_nested_related_items').each(function (i, element) {
      NestedRelatedItems.init($(element)); // eslint-disable-line no-undef
    });
  });

  // Metadata page
  $('.mods_display_nested_related_items').each(function (i, element) {
    NestedRelatedItems.init($(element)); // eslint-disable-line no-undef
  });
});
