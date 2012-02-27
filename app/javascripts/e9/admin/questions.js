;jQuery(function($) {
  /*
   * admin faq questions select actually changes the window location on change
   */
  $("body.controller-admin-questions .toolbar select").change(function() {
    window.location = location.pathname.replace(/faqs\/([^[\/]*)\/questions/, 'faqs/'+$(this).val()+'/questions');
  });
});
