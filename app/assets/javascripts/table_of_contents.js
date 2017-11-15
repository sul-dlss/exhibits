/* global Blacklight */

Blacklight.onLoad(function() {
  $('.blacklight-toc_search').on('show.bs.collapse hide.bs.collapse', function(){
    var _this = $(this);
    var linkText = $(_this).find('span');

    $(_this).find('.caret').toggleClass('caret-right');
    $(linkText).text(linkText.text() == 'Show' ? 'Hide' : 'Show' );
  });
});
