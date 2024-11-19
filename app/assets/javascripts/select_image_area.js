/* eslint-disable camelcase */
/* global Blacklight */

(function (global) {
    var SelectImageArea;
  
    SelectImageArea = {
      init: function(el) {
        this.panel = $(el);
  
        this.destroyExistingImageAreaModal();
        this.destroySelectImageAreaLink();
  
        this.addSelectImageAreaLink();
        // TODO: make this work in a modal (see below)
        // this.addSelectImageAreaModal();
      },
  
      addSelectImageAreaLink: function() {
        const target = $('[data-panel-image-pagination]', this.panel); // Use this.panel
  
        const resourceId = this.panel.data('resource-id'); // Use this.panel
        console.log(this.panel.data)
        const selectImageAreaHtml = $('<a class="nav-link" id="select-image-area" href="/default-exhibit/select_image_area/' + resourceId + '">Edit image area</a>');
  
        // TODO: make this work in a modal (see below)
        // const selectImageAreaHtml = $('<a class="nav-link" id="select-image-area" data-blacklight-modal="trigger" href="/default-exhibit/select_image_area/xy658qf4887">Edit image area</a>');
        target.before(selectImageAreaHtml);
      },
  
      destroyExistingImageAreaModal: function() {
        var imageAreaModal = $('#image-area-modal', this.panel); // Use this.panel
        imageAreaModal.html('');
      },
  
      destroySelectImageAreaLink: function() {
        const selectImageAreaLink = $('#select-image-area', this.panel); // Use this.panel
        selectImageAreaLink.remove();
      }
    };
  
    global.SelectImageArea = SelectImageArea;
  }(this));
  
  Blacklight.onLoad(function () {
    'use strict';
  
    $('[data-type="solr_documents_embed"] .panels li').each(function (i, element) {
      SelectImageArea.init(element); // eslint-disable-line no-undef
    });
  });
  