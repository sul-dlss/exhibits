/* global Blacklight */

Blacklight.onLoad(function() {

  $('.blacklight-text_titles_tesim').on('click', function(){
    var _this = $(this);
    var linkText = $(_this).find('span');

    $(_this).find('.caret').toggleClass('caret-right');
    $(linkText).text(linkText.text() == 'Show' ? 'Hide' : 'Show' );
  });
});
