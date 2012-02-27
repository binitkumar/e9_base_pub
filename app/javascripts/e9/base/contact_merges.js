;jQuery(function() {

  var email_regex = /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i;

  $('.contact-email input').live('blur', function() {
    var 
    $el     = $(this), 
    email   = $el.val(),
    $md     = $('#merge-dialog'),
    buttons = {},
    action,
    data,
    id,
    existin = $el
      .closest('.record-attribute')
      .siblings('.record-attribute')
      .find('.contact-email input')
      .map(function(i, el){ return $(el).val(); });

    if (_.include(existin, email)) {
      $('#duplicate-dialog').dialog({
        close: function() { $el.val(''); },
        resizable: false,
        modal: true,
        buttons: {
          'Ok': function() { $(this).dialog("close"); }
        }
      });
    } else if (email_regex.test(email)) { 
      data = 'email='+email;
      id   = $md.attr('data-id');

      if (id) { data+='&id='+id; }

      $.ajax({
        url: '/users/email_test.json',
        data: data,
        success: function(data) {
          if (data.url) {
            action = id ? 'Yes, merge now' 
                        : 'Yes, edit now';

            buttons[action] = function() {
              window.location.href = data.url;
            }

            buttons['Cancel'] = function() {
              $( this ).dialog( "close" );
            }

            $md.dialog({
              close: function() { $el.val(''); },
              resizable: false,
              modal: true,
              buttons: buttons
            });
          }
        }
      });
    }
  });
});
