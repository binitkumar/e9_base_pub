;jQuery(function($) {
  $('body.controller-attachments')
    // hook to tag images and reload the page
    .bind('e9:upload:complete', function(event, file) {
      $.fn.colorbox({ 
        href:       '/file_uploads/'+file.id+'/edit',
        scrolling:  false,
        width:      600,
        onClosed: function() {
          window.location = '/file_uploads';
        }
      });
    })

    // uploadify initializer
    .each(function(i, el) {
      $('#file-upload-input', el).uploadify({
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
    })
  ;

  // code for the attachment forms

  var 
  img_rx  = /(jpe?g|png|gif|bmp)$/i,
  html_rx = /html?$/i,
  pdf_rx  = /pdf$/i,
  xls_rx  = /xls$/i,
  doc_rx  = /(docx?|rtf)$/i,
  ppt_rx  = /ppt$/i;

  $('li.attachment .delete-attachment').live('click', function(e) {
    var $this = $(this),
        $dest = $('input[type=hidden]', $this),
        $li   = $this.closest('.attachment');

    $li.fadeOut(function() {
      if ($dest.length) {
        $dest.val('1');
      } else {
        $li.remove();
      }
    });
  });

  $('li.attachment-form input[type=file]').live('change', function(e) {
    var $this = $(this),
        $li   = $this.closest('li.attachment-form'),
        val   = $this.val(),
        klass,
        $new_li;

    if (val) {
      if (val.match(img_rx)) {
        klass = 'image';
      } else if (val.match(pdf_rx)) {
        klass = 'pdf';
      } else if (val.match(html_rx)) {
        klass = 'html';
      } else if (val.match(xls_rx)) {
        klass = 'xls';
      } else if (val.match(doc_rx)) {
        klass = 'doc';
      } else if (val.match(ppt_rx)) {
        klass = 'ppt';
      } else {
        klass = 'file';
      }

      function inc(i, val) {
        return val.replace(/\d+/, function(n){ return ++n })
      }

      $new_li = $li.clone();

      $li
        .removeClass('attachment-form')
        .removeClass('last')
        .addClass('attachment')
        .find('input[type=file]')
          .css('display', 'none')
          .before('<div class="attachment-icon attachment-'+klass+'" title="'+val+'" />')
          .before('<span title="Remove this file" class="delete-attachment">Remove</span>')
      ;

      $new_li
        .find('input[type=hidden]').each(function(i, el) {
          $(el).attr('name', inc).attr('id', inc);
        }).end()

        .find('input[type=file]')
          .attr('name', inc)
          .attr('id', inc)
          .val('')
        .end()

        .insertAfter($li)
      ;
    }
  });
});
