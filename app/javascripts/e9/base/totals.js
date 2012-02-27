;jQuery(function() {
  (function() {
    var 
    options, selector,

    defaults = {
      total: '#ctotal', 
      costs: 'tbody .cost',
      row_value: function(el) {
        return Number($('input[type=text]', el).val());
      }
    },

    sum = function() {
      var n, costs, costs_sel;

      costs_sel = /radio/.test(options.costs) 
          ? options.costs + '[checked]' 
          : options.costs;

      costs = $(costs_sel, selector);

      return _.reduce($.makeArray(costs), function(memo, el){ 

        el = $(el);
        n  = options.row_value(el);

        if (isNaN(n)) {
          el.addClass('field_with_errors');
        } else {
          el.removeClass('field_with_errors');
        }

        return memo + n;
      }, 0)
    },

    calculate = function() {
      var s = sum(), total = $(options.total, selector), html;

      if (isNaN(s)) {
        html = 'Oops!  Numbers only.';
        total.addClass('error');
      } else {
        //html = _.sprintf(s > 0 ? "$%.2f" : "- $%.2f", s);
        html = _.sprintf("$%.2f", s);
        total.removeClass('error');
      }

      $.event.trigger('e9-totals:total', s);

      total.html(html);

      return html;
    },

    init = function(opts) {
      var that = this, costs, events;

      // NOTE This is really intended for one list of fields on
      //      a page.  If we wanted to have multiple sums it'd have to
      //      be changed to use data() or something.
      return this.each(function(i, el) {
        options = $.extend({}, defaults, opts);
        selector = $(that).selector;

        costs = $(options.costs, selector);

        if (costs.is(':radio')) {
          events = 'change';
        } else {
          events = 'keyup input';
        }

        costs.live(events, calculate);

        calculate();
      })
    };

    $.fn.totals = function(opts) {
      var api = {
        calculate: calculate
      }

      if (api[opts]) {
        return api[opts].apply(this, Array.prototype.slice.call(arguments, 1));
      } else if ( typeof opts === 'object' || !opts) {
        return init.apply(this, arguments);
      } else {
        $.error('Method '+ opts +' does not exist on $.totals');
      }    
    }
  })();

  $('#dated-costs-bulk').totals();

  $('#balance-table')
    .totals({
      row_value: function(el) {
        return Number(el.text());
      }
    })
    .find('a[data-method=delete]').live('ajax:success', function(e) {
      $('#records_table').totals('calculate');
    })
  ;
});
