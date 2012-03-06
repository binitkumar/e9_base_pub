;jQuery(function($) {

  var 

  _f,

  bot_field = '\
<div class="field checkbox cbc-field-2">\
  <input id="cb_optin_2_INDEX" type="checkbox" name="cb_optin_2" />\
  <label for="cb_optin_2_INDEX" class="req">I am a spambot</label>\
</div>',
      
  human_field = '\
<div class="field checkbox cbc-field-1">\
 <input id="cb_optin_1_INDEX" \
     type="checkbox" name="cb_optin_1" class="required" />\
  <label for="cb_optin_1_INDEX" class="req">\
   Check here if you are a real person \
   <span class="help" rel="tooltip" title=\
     "This feature helps prevent robots from submitting this form.<br /><br />\
     A &ldquo;robot&rdquo; is a program that automatically traverses the web \
     looking for vulnerable website forms. Its goal is to create accounts that \
     it could then use to send spam.">[?]</span>\
 </label>\
</div>';

  (_f = function() {
    $('form .cbc:empty').each(function(i, el) {
      $(el)
        .closest('form').bind('ajax:complete', function(e, xhr) {
          if (xhr.status == 205) { $(this).replaceWith('Thanks!') }
        }).end()
        .append(
          $('<fieldset class="cbc-fields checkbox"/>')
            .append(bot_field.replace(/INDEX/g, i))
            .append(human_field.replace(/INDEX/g, i))
        )
      ;
    });
  })();

  $(document).ajaxComplete(_f);
});
