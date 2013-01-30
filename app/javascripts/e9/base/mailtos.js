;jQuery(function() {
  /*
   * contact mailto links have template functionality, passing the contact and user (login) 
   * for the email to the email templates form, which offers the available templates and
   * on submit, will return the template in its rendered form for population of a mailto.
   *
   * See below handling of the form.
   */
  $('a.contact-mailto').live('click', function(e) {
      var $a = $(this);

      if (!$a.data('qtip')) {
        $a.qtip({
          content: {
            title: { text: 'Send Contact Email', button: true },
            text: '<img src="/images/spinner.gif" />',
            ajax: {
              url: '/admin/email/templates/select',
              dataType: 'html',
              data: {
                to: $a.text(),
                contact_id: $a.attr('data-contact-id'),
                user_id: $a.attr('data-user-id'),
                type: $a.attr('data-type')
              }
            }
          }, 
          position: { at: 'bottom center', my: 'top center' },
          show: false,
          hide: 'unfocus',
          style: { classes: 'ui-tooltip-wiki ui-tooltip-light ui-tooltip-shadow' }
        })
      }

      $a.qtip('show');
      return false;
    })
  ;

  /*
   * Behavior for the email template select form.
   *
   * It should intercept the submit and redirect itself to email_templates#show.json
   * passing along the user_id and contact_id sent with the request.
   *
   * On success, it should take the json returned (the rendered email template data) and 
   * build a mailto href which is then opened in a new window.
   */
  $('form.email-template-sel').live('submit', function(e) {
    e.preventDefault();

    var $t = $(this), 
        $s = $t.find('select'),
        $c = $t.find('> input[type=hidden]');

    $.ajax({
      url: $t.attr('action')+'/'+ $s.val() +'/personalize',
      type: 'GET',
      dataType: 'json',
      data: $.param($c),
      success: function(data, status, xhr) {
        var   to = data.to,
            subj = escape(data.subject),
            body = escape(data.text_body);

        var href = 'mailto:' + to + '?subject=' + subj + '&body=' + body;

        // attempt to close our tooltip
        try { $t.closest('.ui-tooltip').qtip('api').hide(); } catch(e) {}

        // open mailto in new window
        window.open(href, '_blank');
      }
    });
  });
});
