;jQuery(function($) {
  $('body.admin table.records a.view-poll-results').colorbox({
    transition: 'none',
    width: '35%',
    height: '50%',
    onComplete: function() {
      $('#cboxLoadedContent div.poll-question').replaceWith(function(i, content) {
        return "<h1>" + content + "</h1>";
      });
    }
  });

  $('.renderable.poll form #poll_submit').live('click', function(e) {
    e.preventDefault();

    var el = $(this).closest('form');

    // return if no selection
    if (!$("input[@name='poll[vote]']:checked").val()) return;

    $.ajax({
      url: el.attr('action'),
      dataType: 'json',
      type: 'POST',
      data: el.serializeArray(),
      success: function(data, status, xhr) {
        el.closest('.renderable.poll').html(data.html);
      }
    });
  });

  $('.poll .view-poll-results, .poll .view-poll-form').live('click', function(e) {
    e.preventDefault();
    var el = $(this);

    $.ajax({
      url: el.attr('href'),
      dataType: 'json',
      type: 'GET',
      success: function(data, status, xhr) {
        el.closest('.renderable.poll').html(data.html);
      }
    });
  });

  /*
   * add poll class handler to quick_edit.
   *
   * TODO Come up with a nicer method of setting defaults
   *
   * NOTE It's probably overkill and unnecessary to worry about load order, 
   *      which is the complicating factor here.
   */
  $.quick_edit = $.quick_edit || {};
  $.quick_edit.class_handlers = $.extend({
    'poll' : function(el) {
      var path   = el.attr('data-renderable-path'), 
          npath  = el.attr('data-update-node-path'),
          //rpath  = path + '/replace?node_id=' + el.attr('data-node'),
          epath  = path + '/edit';

      return '<a class="qe-qelink" href="'+ epath +'">Edit</a>' +
             '<a class="qe-ulink"  href="'+ npath +'">Switch</a>' +
             '<a class="qe-elink"  href="'+ epath +'">Admin</a>';
    }
  }, $.quick_edit.class_handlers);
});
