/* global Blacklight */

Blacklight.onLoad(function(){
  var uniqueId = (function() {
  		var uuid = 0;

  		return function(el) {
        el.id = 'ui-id-' + ( ++uuid );
  		};
  	} )();

  $('dd.blacklight-full_text_tesimv').addClass('collapse').each(function() {
    $(this).attr('id', uniqueId(this));
  });

  $('dt.blacklight-full_text_tesimv').each(function() {
    $(this).text($(this).text().replace(/:$/, ''));
    $(this).append('<span class="caret caret-right"></span>');
    $(this).attr('data-toggle', 'collapse');
    $(this).attr('data-target', '#' + $(this).next('dd').attr('id'));
  });

  $('dd.blacklight-full_text_tesimv').collapse({ toggle: false });
  $('dd.blacklight-full_text_tesimv').on('show.bs.collapse hide.bs.collapse', function(){
    $(this).prev().find('.caret').toggleClass('caret-right');
  });
});
