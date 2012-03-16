;(function($) {
  $.e9 = $.e9 || {};
  var 
  method_name = 'image_upload',

  public_method = $.fn[method_name] = function(options) {
    return this.each(function(i, el) {
      var $this = $(el), $input;

      if ($this.data('image_upload')) return false;
      $this.data('image_upload', true);

      // The "reset" link is local in the case of new records, and remote
      // for persisting ones.
      //
      // We'll bind to ajax:success to handle the latter case, but before that,
      // we also bind to click to determine whether to continue to send the request,
      // or to do the work locally (resetting the temporary uploaded image and
      // clearing the form data for the mount)
      $this.find('a.reset')
        .bind('ajax:success', function(e, data, status, xhr) {
          var el, loc;

          if (options.reload) {
            el  = $(this).closest('.image-mount-wrapper');
            loc = el.attr('data-url')
          } else {
            el  = $(this).closest('.image-mount');
            loc = xhr.getResponseHeader('Content-Location');
          }

          $.get(loc + '/edit', { index: el.attr('data-index') }, function(html) {
            el[options.reload ? 'html' : 'replaceWith'](html);
          });
        })

        .live('click', function(e) {
          var anchor = $(this);

          // if this link isn't pointed to a persisted resource we'll
          // stop propagation on the event to keep it from being handled by
          // the rails ajax driver ...
          if (anchor.attr('href') == '#') {
            e.stopPropagation();

            // then ...
            anchor
              // hide the link
              .hide()

              // and the sibling crop link
              .siblings('a.crop')
                .hide()
              .end()

              // clear the mount fields in the form if they exist
              .closest('.action-buttons')
                .siblings('.mount-fields')
                  .empty()
                .end()
              .end()

              // and revert the src of the image
              .closest(".action-buttons")
                .siblings('.attachment')
                  .find('img')
                    .attr('src', function() {
                      return $(this).attr('data-orig-src')
                    })
                    .removeAttr('data-orig-src');

            return false;
          }
        })
      ;

      $input = $('#'+options.inputID, $this);

      var tags     = $this.attr('data-tags'),
          has_tags = typeof tags !== 'undefined' && tags !== false,
          data     = {};

      if (tags) {
        $.extend(options.scriptData, {
          "image[images__h___tag_list]": tags.split('|').join(',')
        });
      }

      // Handle Uploadify
      $input.uploadify($.extend({
        script: "/image_uploads",
        method: "post",
        hideButton: true,
        wmode: "transparent",
        uploader: "/swf/uploadify.swf",
        fileDataName: "image[attachment]",
        auto: true, //!has_tags,
        cancelImg: "/images/buttons/cancel.png",
        onComplete: function(evt, id, fileObj, response) { 
          var image = $.parseJSON(response);
          $.event.trigger("e9:upload:complete", [image]);
        },
        scriptData: {},
        sizeLimit: 1024 * 1000 * 5, // 1mb * 5
        onError: function(event, ID, fileObj, errorObj) {
          // catch file size errors to give a more descriptive message
          console.dir(errorObj);

          if (errorObj.type == "File Size") {
            $("#" + $this.attr("id") + ID)
              .addClass("uploadifyError")
              .find(".percentage")
                .text("").end()
              .find(".fileName")
                .text(function(e, v){
                  var max  = Math.round(parseInt(errorObj.info) / 1024000 * 100) / 100,
                      size = v.replace(/[^(]*/, "");

                  return "Your upload is too large "+size+". The maximum upload size is "+max+"MB.";
                })
              ;

            return false;
          }
        }
      }, options));
    });
  }
})(jQuery);
