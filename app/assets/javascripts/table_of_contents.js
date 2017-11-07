/* global Blacklight */

Blacklight.onLoad(function() {

  var link = $('.blacklight-text_titles_tesim').find('a');

  $('#collapseToc').on('show.bs.collapse', function () {
    $(link).find('.caret').removeClass('caret-right');
    $(link).html($(link).html().replace('Show', 'Hide'));
  });

  $('#collapseToc').on('hide.bs.collapse', function () {
    $(link).html($(link).html().replace('Hide', 'Show'));
    $(link).find('.caret').addClass('caret-right');
  });
});
