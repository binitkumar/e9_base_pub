;jQuery(function($) {
  var $base_selector = $("body.controller-admin-submenus");

  $("a.add-submenu", $base_selector).click(function(e) {
    e.preventDefault();
    window.location = $(this).attr('href') + "?parent_id=" + $('#submenu-view #menu_id', $base_selector).val();
  });

  /*
   * on change behavior for submenus parent dropdown, note that "main" is assumed as the base url for the 
   * main menu, which is typically id:1
   */
  $("#submenu-view select", $base_selector).change(function(e) {
    $.get(location.pathname.replace(/\d+|main/, $(this).val()), null, null, 'script');
  });
});
