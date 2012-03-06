;jQuery(function($) {
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
