;jQuery(function() {

  //$('body.controller-images.template-index .tags a').live('click', function(e) {
    //e.preventDefault();

    //var tag = $(this).text();

    //if ($.query['tagged[]'] !== [tag]) {
      //tag_update([tag]);
    //} 
  //});
  
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
