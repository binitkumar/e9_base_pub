;jQuery(function() {
  $('#records_table form.toggle_event_attended :checkbox').live('change', function(e) {
    $(this).closest('form').callRemote();
  });

  $.validator.addMethod('uniq', function(val, el) {
    var existing, selector, arr;

    el = $(el);

    if (el.attr('data-selector')) {
      arr = $.makeArray($(el.attr('data-selector')).not(el));

      if (arr && arr.length) {
        existing = $.makeArray(arr).map(function(el) {
          return $(el).val();
        });

        if (_.include(existing, el.val())) {
          this.settings.messages[el.attr('name')] = "You cannot register the same email twice";
          return false;
        }
      }
    } 

    if (el.attr('data-eval')) {
      existing = eval(el.attr('data-eval'));

      if (existing instanceof Array && _.include(existing, el.val())) {
        this.settings.messages[el.attr('name')] = 
            el.val() + " is already registered for this event.";

        return false;
      }
    }

    return true;
  });

  $.validator.addMethod('promo-code', function(val, el) {
    if (val) return true;

    var cost = $(el).closest('.nested-association').find('input.cost:checked');
    return !cost.hasClass('promo-code-required');
  }, 'You must enter a promo-code');

  // retrieve the existing emails for this registration
  $('#event-json').each(function(i, el) {
    $.getJSON($(el).attr('data-url'), function(data) {
      if (data && data.registrations) {
        window.event_emails = _.pluck(data.registrations, 'email');
      }
    })
  });

  $.fn.load_event_form = function(url) {
    var $this = $(this), selector = $(this).selector;

    $this.load(url, function() {

      $this.bind('e9-totals:total', function(e, total) {
        if (total > 0) {
          $('#ctotal-toggle:hidden').show();
        } else {
          $('#ctotal-toggle:visible').hide();
        }
      });
      
      /* fn#totals comes from e9_crm.js */
      $(selector).totals({
        costs: "input.cost:radio",
        row_value: function(el) {
          return Number($(el).val());
        }
      });

      /* recalculate on add/remove event registrations */
      $this.bind('e9-attributes:change', function() {
        $(selector).totals('calculate');
      });
    }) 
  }
});
