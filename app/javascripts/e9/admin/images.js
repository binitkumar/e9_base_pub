;jQuery(function() {
  $('body.controller-images.template-index').bind('e9:upload:complete', function(event, image) {
    $.fn.colorbox({ 
      href:       '/image_uploads/'+image.id+'/edit',
      scrolling:  false,
      onClosed: function() {
        window.location = "/image_uploads";
      }
    });
  });
});
