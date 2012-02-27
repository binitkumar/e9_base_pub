;jQuery(function($) {
  $.extend($.fn.colorbox.settings, {
    opacity: 0.5
  });

  // "popups" use ajax to load content then populate colorbox, giving more flexibility,
  // but requiring that the controllers they're hitting know how to respond to js
  // requests with html.
  $(".popup a, a[rel=popup]").live('click', function(e) {
    e.preventDefault();

    $.fn.colorbox({
      href: $(this).attr('href'),
      scrolling: false,
      onComplete: function() {
        $.ensureTextareaMaxlength();
      }
    });
  });

  /** 
   * Open images in colorbox
   * NOTE: dependent on regex filter
   */
  $("a:regex(href,(jpg|jpeg|gif|png)(\\?\\d+)?$)").live('click', function(e) {
    e.preventDefault();
    $.colorbox({ 
      href: $(this).attr('href'), 
      rel: 'nofollow',
      photo: true,
      scalePhotos: true,
      maxHeight: '95%',
      maxWidth: '95%'
    });
  });

  $("a[rel=lightbox]").live('click', function(e) {
    e.preventDefault();

    $.fn.colorbox({
      html: $(this.getAttribute('href')).html()
    });
  });
});
