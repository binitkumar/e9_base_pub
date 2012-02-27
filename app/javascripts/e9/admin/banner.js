;jQuery(function($) {
  $("body.controller-admin-banners .banner-images")
    .admin_sortable({
      handle: 'img', 
      items: '.image'
    })
  ;

  $("body.controller-admin-banners").bind('e9:crop:success', function() {
    window.location.reload();
  });

  $("body.controller-admin-banners .image a[data-method=delete]").live('ajax:success', function() {
    $(this).closest('.image').fadeOut(function() {
      $(this).remove();
    });
  });
});
