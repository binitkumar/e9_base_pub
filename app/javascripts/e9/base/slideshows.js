;jQuery(function($) {
  $('.controller-slideshows .show-more-link').click(function(e) {
    if (e) e.preventDefault();
    var el = $(this).closest('.slideshow').find('.slide-slice:hidden');
    if (el.size() == 1) $(this).fadeOut();
    el.first().slideDown();
  });
});
