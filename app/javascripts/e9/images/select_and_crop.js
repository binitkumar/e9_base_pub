(function($) {
  $.e9 = $.e9 || {};

  var
  inited = false,

  api = $.e9.select_image = {
    init: function() {
      if (inited) return false;
      inited = true;

      $('a.do-select').live('click', function(e) {
        e.preventDefault();

        $.getJSON(this.href, function(image) {
          var el = api.element;

          $.extend(el.data('crop'), {
            image: image,
            image_id: image.id
          })

          /* NOTE 
           *
           * There's no actual "crop" information here, "select and crop" 
           * depends on the element already being intialized with the crop api 
           * via #crop or #upload_and_crop.
           *
           * So if a Slide has no dimensions, for example, #openCropbox will
           * fail because the element has no crop options.
           */
          $.e9.crop.element = el;
          $.e9.crop.openCropbox();
        });
      });
    }
  }

  $.fn.select_and_crop = function() {
    $.e9.crop.init();
    api.init();

    var scope = this.selector;

    $(scope + ' a.select').live('click', function(e) {
      e.preventDefault();

      api.element = $(this).closest(scope);

      $.fn.colorbox({ href: this.href });
    });

    return this;
  }

  $(function() {
    $('.image-mount.field').select_and_crop();

    $('.image-management input[type=checkbox]').live('change', function(e) {
      $(this).closest('form').callRemote();
    });
  })
})(jQuery);
