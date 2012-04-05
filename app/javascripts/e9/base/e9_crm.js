;jQuery(function($) {
  /*
   * add offer class handler to quick_edit.
   */
  $.quick_edit = $.quick_edit || {};
  $.quick_edit.class_handlers = $.extend({
    'offer' : function(el) {
      var path   = el.attr('data-renderable-path'), 
          npath  = el.attr('data-update-node-path'),
          epath  = path + '/edit';

      return '<a class="qe-ulink"  href="'+ npath +'">Switch</a>' +
             '<a class="qe-elink"  href="'+ epath +'">Admin</a>';
    }
  }, $.quick_edit.class_handlers);

  $('body.template-payments form.new_dated_cost').live('ajax:success', function(e, data, status, xhr) {
    if (xhr.status == 201) {
      location.href = '/admin/crm/contacts/payments';
      $.colorbox.close();
    }
  });

  $('body.controller-e9-crm-dated-costs.template-index form.new_dated_cost, ' +
        'body.controller-e9-crm-dated-costs.template-index form.edit_dated_cost').live('ajax:success', function(e, data, status, xhr) {
    if (xhr.status == 201 || xhr.status == 204) {
      location.href = xhr.getResponseHeader('Location');
      $.colorbox.close();
    }
  });

  $("#campaign_code_field input").keyup(function() {
    $.event.trigger('campaign_code_change', [$(this).val()]);
  });

  $("#campaign_code_hint").bind("campaign_code_change", function(e, code) {
    $(this).html(function(i, v) {
      return v.replace(/=(.*)$/, '='+code);
    });
  });

  var selector_prefix = 'body.controller-e9-crm-contacts', 
      $selector       = $(selector_prefix);

  /*
   * The status of "primary" for a User login is stored on the individual records, but must be exlcusive in
   * the scope of the Contact (only one User may be primary).
   */

  $.fn.exclusiveCheck = function() {
    var selector = $(this);

    return this.each(function(i) {
      var $this = $(this);

      if (! $this.data('excl') ) {
        $this.click(function(e) {
          var clicked = this;
          if (this.checked) {
            $this.data('excl').each(function() {
              if (this != clicked) this.checked = false;
            });
          }
        });
      }

      $this.data('excl', selector);
    });
  }

  var rsel = '.nested-association input[type=radio][name$="[primary]"]',
     $rsel = $(rsel);

  if (!$rsel.is(':checked')) { $rsel.first().attr('checked', true); }

  /* wrapped in live to ensure dynamic added fields get the function */
  $(rsel).live('click', function() {
    if (!$(this).data('excl')) {
      $(rsel).exclusiveCheck();
      $(this).click();
    }
  });

  //$('form#contact_search_form', $(selector_prefix))
    //.live('submit', function(e) {
      //e.preventDefault();

      //$.extend($.query, {
        //'search': $(this).find('input[name=search]').val()
      //});

      //$.submit_with_query();
    //})
    //.each(function(i, el) {
      //$('input[type=text]', el).val($.query['search'] || '');
    //})
  //;

  $('a[rel=clear]', $(selector_prefix))
    .live('click', function(e) {
      e.preventDefault();

      $(selector_prefix)
        .find('select').val('').end()
        .find('input[type=text]').val('').end()
        .find('#contact_tag_select').html('').end()
        .find('input[type=checkbox]').attr('checked', false).end()
      ;

      $.query = {};

      $.submit_with_query();
    })
  ;

  $('.contact-select a').live('click', function(e) {
    e.preventDefault();
    $(this)
      .closest('.contact-select')
        .hide()
        .setContactSelectValues('', null)
        .prev('.contact-autocomplete')
          .show()
    ;
  });

  $.fn.setContactSelectValues = function(text, id) {
    $('.content', this).html(text);
    $('input', this).val(id).change();
    return this;
  }

  $(".email-campaign-autocomplete:not(.ui-autocomplete-input)").live("focus", function (event) {
    $(this)
      .autocomplete({
        source: '/autocomplete/email_campaigns',
        delay: 400
      })
      .bind('keypress', function(e) {
        if (e.keyCode == 13) e.preventDefault();
      })
    ;
  });

  /*
   * Contact autocomplete
   */

  /*
   * Single autocomplete (not select/list widget)
   */
  $('input.contact-autocomplete.single:not(.ui-autocomplete-input)').live('click', function(e) {
    $(this).each(function(i, el) {
      el = $(el);
      el
        .bind('keypress', function(e) {
          if (e.keyCode == 13) e.preventDefault();
        })
        .autocomplete({
          delay: 400,
          source: '/autocomplete/contacts',

          // on select, add the template (code is in widgets.js) and
          // clear the input field
          select: function(e, ui) {
            el
              .hide().val('')
              .next('.contact-select')
              .setContactSelectValues(ui.item.value, ui.item.id)
              .show()
            ;
            return false;
          }
        })
      ;
    });
  });

  $('input.deal-autocomplete.list:not(.ui-autocomplete-input)').live('click', function(e) {
    $(this).each(function(i, el) {
      el = $(el);

      el
        .bind('keypress', function(e) {
          if (e.keyCode == 13) e.preventDefault();
        })
        .autocomplete({
          delay: 400,

          // on select, add the template (code is in widgets.js) and
          // clear the input field
          select: function(e, ui) {
            el
              .add_select_template(ui.item.value, ui.item.id)
              .val('');

           // return false to prevent autocomplete from filling the field
           return false;
          },
          source: function(request, response) {

            var data = 'query=' + request.term, 
                excl = el.attr('data-values');

            // add 'except' ids if they exist in values.
            if (excl) data += '&except=' + excl;

            $.ajax({
              url: "/autocomplete/deals",
              dataType: "json",
              data: data,
              success: function(data) {
                response(data);
              }
            });
          }
        })
      ;
    });
  });

  $('input.contact-autocomplete.list:not(.ui-autocomplete-input)').live('click', function(e) {
    $(this).each(function(i, el) {
      el = $(el);

      el
        .bind('keypress', function(e) {
          if (e.keyCode == 13) e.preventDefault();
        })
        .autocomplete({
          delay: 400,

          // on select, add the template (code is in widgets.js) and
          // clear the input field
          select: function(e, ui) {
            el
              .add_select_template(ui.item.value, ui.item.id)
              .val('');

           // return false to prevent autocomplete from filling the field
           return false;
          },
          source: function(request, response) {

            var data = 'query=' + request.term, 
                excl = el.attr('data-values');

            // add 'except' ids if they exist in values.
            if (excl) data += '&except=' + excl;

            $.ajax({
              url: "/autocomplete/contacts",
              dataType: "json",
              data: data,
              success: function(data) {
                response(data);
              }
            });
          }
        })
      ;
    });
  });

  var $company_autocomplete = $('#contact_company_name');

  $company_autocomplete
    .autocomplete({
      delay: 400,
      focus: function(e, ui) {
        $company_autocomplete.val(ui.item.value);
        return false;
      },
      source: function(request, response) {
        $.ajax({
          url: "/autocomplete/companies",
          dataType: "json",
          data: request,
          success: function(data) {
            // caching code, not impl
            //search_cache.term = request.term;
            //search_cache.content = data;
            response(data);
          }
        });
      }
    })
  ; 

  $('.renderable form.new_deal').livequery('submit', function(e) {
    e.preventDefault();

    var $f = $(this);

    // if the validator has not been defined
    if (!$f.data('validator')) {

      // define it, including an ajax submit handler
      $f.validate({
        onclick: false,
        onfocusout: false,
        onkeyup: false,
        errorClass: 'field_with_errors',
        errorElement: 'div',
        submitHandler: function(v) {
          $f.callRemote();
        }
        ,errorPlacement: function(label, element) {
          
          element.closest(".field").append(label);
        }
      });

      // then re-submit, to the now validated form
      $f.submit();
    }
  });

  $('#records_table td.lead-followed-up :checkbox').live('change', function(e) {
    $(this).closest('form').callRemote();
  });
});
