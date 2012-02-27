;jQuery(function() {
  $("body.controller-admin-slides").bind('e9:crop:success', function(e, el, opts) {
    if (opts.reload) {
      var w = el.closest('.image-mount-wrapper');

      $.get(opts.script + '/edit', { index: w.attr('data-index') }, function(html) {
        w.html(html);
      });
    }
  });
});
