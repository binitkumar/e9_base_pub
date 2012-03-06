;(function($) {
  $.e9 = $.e9 || {};

  var
  api_name    = 'upload_and_crop',
  method_name = 'upload_and_crop',

  api = $.e9[api_name] = { },

  uploadify_handler = function(el) {
    return function(evt, id, fileObj, response) {
      var image = $.parseJSON(response);

      // Hook in here and offer a chance to edit the tags
      $.fn.colorbox({ 
        href:       '/image_uploads/'+image.id+'/edit',
        scrolling:  false,
        width:      600,

        // and we'll go ahead and reopen the crop window
        // when this colorbox closes
        onClosed: function() {
          if (el.data('crop')) {
            $.extend(el.data('crop'), { image: image })
            $.e9.crop.element = el;
            $.e9.crop.openCropbox();
          } 
        }
      });

      return true;
    }
  },

  public_method = $.fn[method_name] = function(params) {
    $.e9.crop.init();

    return this.each(function(i, el) {
      var $el = $(el);

      $el.crop(params.crop_options);

      $el.image_upload($.extend({ 
        onComplete: uploadify_handler($el)
      }, params.upload_options));
    });
  }

})(jQuery);
