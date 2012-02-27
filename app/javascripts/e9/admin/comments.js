;jQuery(function($) {
  var scope = 'body.controller-admin-comments';

  $('#delete_user_link', scope).live("ajax:success", function(_, _, _, xhr) {
    if(xhr.status == 204) {
      setTimeout(function(){ location.href = "/admin/users"; }, 0)
    }
  });
});
