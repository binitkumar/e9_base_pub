;jQuery(function($) {
  // faqs
  $("body.controller-faqs .question:not("+ (document.location.hash || ".asdf") +") .answer").hide()
  $("body.controller-faqs .question a.question-link").toggle(
    function() { $(this).next(".answer").slideDown('fast'); },
    function() { $(this).next(".answer").slideUp('fast');   }
  );
});
