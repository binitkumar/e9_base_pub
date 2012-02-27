;jQuery(function($) {
  /* swap out faqs by role on select */
  $('body.controller-admin-faqs #faq_role_select').bindSelectChange(function(e) {
    $.get(document.location.pathname +'?role='+ $(this).val(), null, null, 'script');
  });
});
