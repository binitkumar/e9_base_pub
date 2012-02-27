;jQuery(function() {
  $('body.controller-images.template-index').bind('e9:upload:complete', function(event, image) {
    window.location = "/image_uploads";
  });
});
