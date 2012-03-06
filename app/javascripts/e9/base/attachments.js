;jQuery(function() {
  var tag_update = function(tags) {
    $.extend($.query, { 'tagged[]': tags });
    $.submit_with_query();
  }

  $('body.controller-attachments').bind('e9:upload:complete', function(event, file) {
    $.fn.colorbox({ 
      href:       '/file_uploads/'+file.id+'/edit',
      scrolling:  false,
      width:      600,
      onClosed: function() {
        window.location = '/file_uploads';
      }
    });
  });

  var $input = $('#file-upload-input');

  if ($input.length) {
    $input.uploadify({
      script: '/file_uploads.json',
      hideButton: true,
      wmode: "transparent",
      uploader: "/swf/uploadify.swf",
      fileDataName: "attachment[file]",
      auto: true,
      cancelImg: "/images/buttons/cancel.png",
      onComplete: function(evt, id, fileObj, response) { 
        var f = $.parseJSON(response);
        $.event.trigger("e9:upload:complete", [f]);
      },
      queueID: 'file-upload-queue',
      scriptData: {},
      sizeLimit: 1024 * 1000 * 5, // 1mb * 5
      //onSelectOnce: function(e, id, fobj) {
        //$.fn.colorbox({ 
          //href:       '/file_uploads/new',
          //scrolling:  false,
          //width:      600,
          //onComplete: function() {
            //var el = $('#cboxLoadedContent');

            //$("form", el)
              //.removeAttr('data-remote')
              //.submit(function(e) {
                //e.preventDefault();

                //var 
                //sd = $input.uploadifySettings("scriptData");

                //var tags = $("input.tag-input", el).map(function(i, e) {
                  //return $(e).val();
                //});

                //$.extend(sd, {
                  //"attachment[files__h___tag_list]": $.makeArray(tags)
                //});

                //$input.uploadifySettings("scriptData", sd);
                //$input.uploadifyUpload();
              //})
            //;
          //},
          //onClosed: function() {
            //$input.uploadifyClearQueue();
          //}
        //});

        //return false;
      //},
      onError: function(event, ID, fileObj, errorObj) {
        // catch file size errors to give a more descriptive message
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
    });
  }

  $('form[action="/file_uploads"] .tag-autocomplete').not('.ui-autocomplete').each(function(i, el) {
    var 
    $input = $(el), 
    $tags = $input.siblings('ul.select'),
    $untagged = $('#untagged-checkbox'),
    get_tags = function() {
      return $.makeArray($('.content', $tags).map(function(i, tag){ return $(tag).text() }));
    },
    disable_tags = function() {
      $tags.html('');
      delete $.query['tagged[]'];
      $input.attr('disabled', 'disabled').attr('placeholder', '');
    },
    enable_tags = function() {
      $input.removeAttr('disabled').attr('placeholder', 'Enter a tag...');
    }

    /* this is in addition to the usual select.list click */
    $('a', $tags).live('click', function(e) {
      e.preventDefault();
      _.defer(function() { tag_update(get_tags()) });
    });

    $('form.scope-selects').bind('e9:scope-selects:clear', function(e) {
      $tags.html('');
    });

    $untagged
      .attr('checked', function() { 
        var checked = $.query['untagged'] == 'true'; 
        if (checked) disable_tags();
        return checked;
      })
      .bind('change', function(e) {
        e.preventDefault();

        var v = $(this).attr('checked');

        if (v) {
          $.query['untagged'] = 'true';
          disable_tags();
        } else {
          delete $.query['untagged'];
          enable_tags();
        }

        $.submit_with_query();
      })
    ;

    $input
      .blur(function() { $(this).val('') })
      .closest('form').bind('submit', function() { return false }).end()
      .autocomplete({
        delay: 350,

        source: function(request, response) {
          var request_str = "term=" + request.term + "&context=files*";

          if ($.query['tagged[]']) {
            request_str += '&' + $.param({ except: $.query['tagged[]'] });
          }
          
          $.ajax({
            url: "/autocomplete/tags",
            dataType: "json",
            data: request_str,
            success: function(data) {
              var tags = get_tags();

              response(_.select(data, function(obj, i) {
                return !_.include(tags, obj.value);
              }));
            }
          });
        },

        select: function(evt, ui) {
          $input
            .val('').blur()
            .add_select_template(ui.item.value, ui.item.value, $tags);

          tag_update(get_tags());
          return false;
        },

        focus: function(evt, ui) {
          $input.val(ui.item.value);
          return false;
        }
      })

  });
});
