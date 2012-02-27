;(function($) {
  $.e9 = $.e9 || {};

  var
  api_name    = 'crop',
  method_name = 'crop',

  inited      = false,
  jcrop_api,

  crop_box,
  crop_form,
  image_h,
  image_r,
  image_w,
  image_x,
  image_y,
  preview,
  preview_window,

  html = '\
    <div id="crop" class="popup-display">\
      <h1>Crop Your Image</h1>\
      <div class="crop-box">\
        <label for="crop-box">Current Image</label>\
        <img id="crop-box"/>\
      </div>\
      <div class="preview-window">\
        <label for="preview">Preview Your Image</label>\
        <div id="preview-window">\
          <img id="preview"/>\
        </div>\
      </div>\
      <div class="crop-form">\
        <form id="crop-form" method="POST" data-type="json">\
          <input type="hidden" name="_method" />\
          <input type="hidden" name="image_mount[image_id]" class="tocopy" />\
          <input type="hidden" name="image_mount[instructions][0][]" value="crop" class="tocopy" />\
          <input type="hidden" name="image_mount[instructions][0][][x]" value="0" id="image_x" class="tocopy" />\
          <input type="hidden" name="image_mount[instructions][0][][y]" value="0" id="image_y" class="tocopy" />\
          <input type="hidden" name="image_mount[instructions][0][][width]" value="0" id="image_w" class="tocopy" />\
          <input type="hidden" name="image_mount[instructions][0][][height]" value="0" id="image_h" class="tocopy" />\
          <input type="hidden" name="image_mount[instructions][0][][resize]" value="0" id="image_r" class="tocopy" />\
          <input type="submit" value = "Crop"/>\
        </form>\
      </div>\
    </div>\
  ',
  
  api = $.e9[api_name] = {
    element : {},

    defaults: {
      crop_height        : 100,
      crop_width         : 100,
      max_crop_width     : 640,
      max_crop_height    : 480,
      min_window_width   : 500,
      horizontal_padding : 40,
      vertical_padding   : 150
    },

    currentOptions: function() {
      return api.element.data(method_name);
    },

    setCurrentOptions: function(options) {
      $.e9[api_name].element.data(method_name, options);
    },

    // called when the cropbox opens, setting crop behavior
    initJcrop: function() {
      var _w, _h, options = api.currentOptions();

      if (options.aspect_ratio > 1) {
        _w = Math.min(options.crop_width, options.image.width);
        _h = _w / options.aspect_ratio;
      } else {
        _h = Math.min(options.crop_height, options.image.height);
        _w = _h * options.aspect_ratio;
      }

      jcrop_api = $.Jcrop("#crop-box", { 
        boxWidth: options.max_crop_width,
        boxHeight: options.max_crop_height,
        onChange: api.cropSelect,
        onSelect: api.cropSelect,
        aspectRatio: options.aspect_ratio,
        allowSelect: false,
        keySupport: false,
        setSelect: [0, 0, _w, _h]
      });

      image_w.val(options.crop_width);
      image_h.val(options.crop_height);

      // because of boxWidth resizing of images the height can be off
      $.colorbox.resize();
    },

    cleanUp: function() {
      // Change the source of the attached image to reflect the new upload
      var options = api.currentOptions();

      if (inited) {
        jcrop_api.destroy();

        // reset the size & sources of image containers
        preview_window.attr('style', '');
        crop_box.attr('style', '').attr('src', '');
        preview.attr('style', '').attr('src', '');
      }

      $.event.trigger('e9:crop:complete');
    },

    // the submission of the crop
    cropSubmitFormHandler: function(e) {
      e.preventDefault();

      if ( parseInt( image_w.val() ) ) {
        $(this).callRemote();
      } else { 
        alert('Please select a crop region then press submit.');
      }
    },

    // crop handler that sets form values as the crop changes
    cropSelect: function(coords) {
      var options = api.currentOptions(), w, h, x, y, rx, ry;

      if (parseInt(coords.w) > 0) {
        rx = preview_window.width() / coords.w;
        ry = preview_window.height() / coords.h;
        x  = Math.round(rx * coords.x);
        y  = Math.round(ry * coords.y);
        w  = Math.round(rx * options.image.width);
        h  = Math.round(ry * options.image.height);

        image_x.val(x); 
        image_y.val(y);
        image_r.val(w + "x" + h + '!');

        preview.css({
          width:          w+'px',
          height:         h+'px',
          marginLeft: '-'+x+'px',
          marginTop:  '-'+y+'px'
        });
      }
    },

    cropAjaxSuccess: function(e, data, status, xhr) {
      // NOTE that on success, the options.image is replaced with
      // the cropped options.image.  The cropped image still references
      // the original image as image.attachment.
      var options = api.currentOptions();
          options.image = data;

      api.setCurrentOptions(options);

      if (options.image.url) {
        // replace the image source, but first back up the old one. This is
        // helpful for image mounts that depend on their owner for their
        // fallback_url, as temp image_mount records do not have an owner
        $('.attachment img', api.element)
          .attr("data-orig-src", function() { return $(this).attr("src") })
          .attr("src", options.image.url);

        // Ensure the reset link has the right href and is shown
        $('a.reset', api.element).show();
        $('a.crop', api.element).show();
      }

      // In the case that the image_mount is not yet persisted, the data gets 
      // copied into the new image_mount form.
      if (!options.persisted) {
        $('.mount-fields', api.element).each(function(i, el) {
          el = $(el)

          el.find('.tocopy').remove();

          var prefix = el.attr('data-name');

          $('.tocopy', crop_form).each(function(i, field) {
            field = $(field).clone();

            field.attr('name', function(i, v) {
              return v.replace('image_mount', prefix);
            });

            el.append(field);
          });
        });
      }

      $.event.trigger('e9:crop:success', [api.element, options]);
    },

    cropAjaxComplete: function(data, status, xhr) {
      $.fn.colorbox.close();
    },

    openCropbox: function(options) {
      options = options || api.currentOptions();

      crop_form.attr('action', options.script);
      crop_form.find('input[type=submit]').removeAttr('disabled');
      crop_form.find('[name=_method]').val(options.persisted ? 'put' : 'post');

      crop_form.find('[name="image_mount[image_id]"]').each(function(i, el) {
        if (options.image && options.image.id) {
          $(el).val(options.image.id);
        } else {
          $(el).removeAttr('value');
        }
      });

      if (options.aspect_ratio > 1) {
        options.preview_window_width  = Math.min(options.crop_width, options.max_crop_width);
        options.preview_window_height = options.preview_window_width / options.aspect_ratio;
      } else {
        options.preview_window_height = Math.min(options.crop_height, options.max_crop_height);
        options.preview_window_width  = options.preview_window_height * options.aspect_ratio;
      }

      preview_window.css('height', options.preview_window_height).css('width', options.preview_window_width);

      $.each([crop_box, preview], function(i, e) { 
        e.attr('src', options.image.url);
      });

      options.crop_window_width  = Math.max(options.min_window_width, Math.min(options.max_crop_width, Math.max(options.image.width, options.crop_width)));
      options.crop_window_height = Math.min(options.image.height, options.max_crop_height);

      options.window_width       = Math.max(options.crop_window_width, options.preview_window_width) + options.horizontal_padding;
      options.window_height      = options.crop_window_height + options.preview_window_height + options.vertical_padding;

      $.fn.colorbox({ 
        inline:     true,
        href:       "#crop",
        scrolling:  false,
        width:      options.window_width,
        height:     options.window_height,
        onComplete: api.initJcrop,
        onClosed:   api.cleanUp
      });
    },

    initOptions: function(element, params) {
      if (element.data(method_name)) return false;

      var options                 = $.extend({}, api.defaults, params);
          options.aspect_ratio    = parseFloat(options.crop_width) / options.crop_height;
          options.cropAjaxSuccess = api.cropAjaxSuccess;

      element.data(method_name, options);

      return options;
    },

    init: function() {
      if (inited) return; inited = true;

      $("body").append(html);

      image_x = $('#image_x');
      image_y = $('#image_y');
      image_w = $('#image_w');
      image_h = $('#image_h');
      image_r = $('#image_r');
      preview = $('#preview');
      crop_box = $('#crop-box');
      crop_form = $('#crop-form');
      preview_window = $('#preview-window');

      crop_form
        .bind('submit', api.cropSubmitFormHandler)
        .bind('ajax:success', api.cropAjaxSuccess)
        .bind('ajax:complete', api.cropAjaxComplete)
      ;
    }
  },

  // this public method handles crop only
  publicMethod = $.fn[method_name] = function(params) {
    api.init();

    return this.each(function(i, el) {

      var $this   = $(el), 
          options = api.initOptions($this, params);

      if (options) {
        $('a.crop', $this).click(function(e) {
          e.preventDefault();

          $.getJSON(this.href, function(data) {
            $.extend($this.data('crop'), { image: data.attachment });
            api.element = $this;
            api.openCropbox();
          });
        });
      };
    });
  }
})(jQuery);
