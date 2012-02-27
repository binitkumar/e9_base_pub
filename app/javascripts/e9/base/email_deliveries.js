// NOTE this is admin

;jQuery(function() {
  $('form#new_email_delivery input[type=submit]').live('click', function(e) {
    e.preventDefault();

    var $s = $(this), query;

    // the new email_delivery form
    $f = $s.closest('form'), 

    // the sibling select of the input which was pressed, this holds the
    // email id options
    $sel = $s.siblings('select'),

    submitForm = function() {
      $.ajax({
        url: $f.attr('action'),
        data: $.param($sel.add($f.find('[type=hidden]'))),
        type: 'post',
        success: function(data) {
          $.colorbox({ 
            html: data,
            onComplete: function() {
              $('form#new_email_delivery').bind('ajax:success', function(e, data, status, xhr) {
                if (xhr.status == 201) {
                  if ($sel.hasClass('newsletter')) {
                    $sel.find('option:selected').remove();
                  }

                  $.colorbox.close();
                }
              });
            }
          });
        }
      });
    }

    // simply return if there's no selection
    if (!$sel.val()) { return false }

    // alert the data-empty message and return if there are no contacts
    if ($f.find('#contact_ids').blank()) {
      alert($f.attr('data-empty'));
      $f.undisable();
      return false;
    } else {
      submitForm();
    }


    //
    // NOTE the following was an implementation where the form queried for
    // contacts based on the $.query params, but it only worked obviously when
    // it was a contact form, making it very limited.
    //
    //query = _($.query).chain().clone()
              //.tap(function(obj) { 
                //obj['page'] = null;
                //obj['per_page'] = null;
              //})
              //.clean()
              //.value();

    //$.getJSON($f.attr('data-contacts-url'), query, function(data) {

      //// alert the data-empty message and return if there are no contacts
      //if (_.isEmpty(data)) {
        //alert($f.attr('data-empty'));
        //$f.undisable();
        //return false;
      //} 
      
      //// otherwise insert the contact ids into the form and submit it
      //else {
        //$('#contact_ids').val(_.pluck(data, 'id').join(','));
        //submitForm();
      //}
    //});
  });
});
