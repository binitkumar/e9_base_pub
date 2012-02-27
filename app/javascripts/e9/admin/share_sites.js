;jQuery(function($) {
  $(".controller-admin-share-sites input:checkbox").live($.browser.msie ? 'click' : 'change', function() {
    $.ajax({
      type: 'PUT',
      dataType: 'script', 
      url: "/admin/settings/share_sites/" + $(this).val() + "/toggle_enabled"
    })
  });
});
