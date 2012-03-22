;jQuery(function($) {
  // ajax the pagination
  $('#records_table .pagination a').live('click', function (e) {
    e.preventDefault();
    $(this).callRemote();
  });

  // ajax deletes should respond with a request for index if the delete is successful (204)
  $('.tool-buttons a[data-remote][data-method=delete]').live("ajax:success", function(evt, data, status, xhr) {
    if (xhr.status == 204) {
      $.submit_with_query(true);
    }
  });
  
  // submenus is the only admin page that is handled differently
  var _f = function() {
    $('body:not(.controller-admin-submenus) table.sortable').admin_sortable();
    $('body.controller-admin-submenus table.sortable').admin_tbody_sortable();
  }
  $(document).ajaxComplete(_f);
  _f();

  $('.ordered-column a').live('click', function(e) {
    e.preventDefault();

    var qh = $(this).query_hash();

    $.extend($.query, {
      order : qh.order,
      sort  : qh.sort
    });

    $.submit_with_query();
  });
});
