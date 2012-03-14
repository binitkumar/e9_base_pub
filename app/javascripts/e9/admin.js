;jQuery(function($) {
  $('tbody tr').hoverize();

  $('fieldset.advanced-settings').advanced_settings();

  /*
   * carrierwave upload form fields
   */
  $(".field.upload").each(function(i, el) {
    var $el         = $(el),
        $file_input = $(el).find('input:file'),
        $cbox_input = $(el).find('input:checkbox'),
        $reset_btn  = $(el).find('.reset'),
        $current    = $(el).find('.current'),
        $mounted    = $(el).find('.mounted');

    $reset_btn.click(function() {
      $file_input.val(null).trigger('change');
    }).hide();

    $cbox_input.change(function() {
      if ($cbox_input.attr('checked')) {
        $mounted.addClass('disabled');
      } else {
        $mounted.removeClass('disabled');
      }
    });

    $file_input.change(function() {
      $cbox_input.attr('checked', false);
      $cbox_input.trigger('change');

      if ($file_input.blank()) {
        $current.show();
        $reset_btn.hide();
      } else {
        $current.hide();
        $reset_btn.show();
      }
    });
  });

  //$(".field.upload").find("input:checkbox").change(function() {
    //var $this = $(this);

    //if ($this.attr('checked')) {

    //} else {

    //}
  //});

  //$(".field.upload").find("input:file").change(function() {
  //});

  /*
   * "accordionify" options, etc.
   */
  $.fn.accordionify = function(options) {
    $(this).accordion($.extend({
      collapsible: true,
      header: "> legend",
      active: false
    }, options));
  }

  $.fn.admin_sortable = function(options) {
    $(this).sortable($.extend({
      axis: 'y', 
      handle: '.handle',
      cursor: 'pointer',
      items: 'tbody tr',
      opacity: 0.5,
      scroll: true,
      forcePlaceholderSize: true,
      forceHelperSize: true,
      placeholder: 'placeholder',
      tolerance: 'pointer',
      containment: 'document',

      helper: function(e, el) {
        // calculate widths on each element and explicitly
        // set them, so when the helper row gets pulled from
        // the table it won't collapse.
        el.find('td').width(function(i, n) {
          return $(this).width();
        });

        // then return a clone
        return el.clone();
      },
      update: function(e, ui) {
        $.ajax({
          type: 'post',
          url: $(this).closest('form').attr('action'),
          data: $(this).sortable('serialize'),
          dataType: 'script'
        })
      }
    }, options));
  }

  $.fn.admin_tbody_sortable = function(options) {
    $(this).admin_sortable($.extend({
      items: 'tbody',
      helper: function(e, el) {

        // calculate widths on each element and explicitly
        // set them, so when the helper row gets pulled from
        // the table it won't collapse.
        el.find('td')
          .width(function(i, n) { return $(this).width(); })
          //.height(function(i, n) { return $(this).height(); })
        ;

        // then return a clone
        // **AND** wrap it in a table, supposedly this can fix
        // some potential issues with sorting tbody?
        return el.clone().wrap('<table />');
      }
    }, options));
  }

  $("body.controller-admin-blog-posts #blog-post-thumb .unattached img").each(function(i, el) {
    $('#author-select').bind($.browser.msie ? "propertychange" : "change", function(e) {
      var id = $(this).children("option:selected").val();
      $(el).attr('src', window.e9.author_thumb_map[id]);
    });
  });
});
