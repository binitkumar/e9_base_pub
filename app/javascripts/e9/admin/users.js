;jQuery(function() {
  var scope = '.controller-admin-users';

  $('form#user_search_form', scope).live('submit', function(e) {
    e.preventDefault();

    $.extend($.query, {
      'search': $(this).find('input[name=search]').val()
    });

    $.submit_with_query();
  });
});
