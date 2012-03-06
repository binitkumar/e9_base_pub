;jQuery(function($) {
  $.e9 = $.e9 || {};

  /** check if the value of an element is "blank" */
  $.fn.blank = function() {
    return $.trim($(this).val()).length == 0;
  }

  /**
   * sets keyup for selected textareas with a 'maxlength' attribute to
   * limit the number of characters in a field.
   */
  $.fn.ensureTextareaMaxlength = function() {
    $.ensureTextareaMaxlength(this);
    return this;
  }

  $.ensureTextareaMaxlength = function(selector) {
    $(selector || 'body').find("textarea[maxlength]").keyup(function(e) {
      var ml = parseInt(this.getAttribute('maxlength'));
      if(this.value.length >= ml) {
        $(this).val(this.value.substr(0, ml));
        this.scrollTop = this.scrollHeight;
      }
    });
  }

  /** add 'hover' class on mouseover **/
  $.fn.hoverize = function() {
    $(this).hover(
      function() {$(this).addClass('hover')},
      function() {$(this).removeClass('hover')}
    )
  }

  /** NOTE this is deprecated (fixed by jquery versions) */
  $.fn.bindSelectChange = function(callback, live) {
    // NOTE live('change') still does not work in IE sub 8 (or 9?)
    var f = live ? 'live' : 'bind';

    // NOTE this used to send propertychange for IE, but this seems to be handled by jquery now
    //return this[f]($.browser.msie ? 'propertychange' : 'change', callback);
    return this[f]('change', callback);
  }

  /** removes "disabled" attribute, jquery-ui hover class, and blurs */
  $.fn.undisable = function() {
    $('input[type=submit]', this).removeAttr('disabled').removeClass('ui-state-hover').blur();
  }

  /**
   * James Padolsey's Regex selector
   * http://james.padolsey.com/javascript/regex-selector-for-jquery/
   */
  $.expr[':'].regex = function(elem, index, match) {
    var matchParams = match[3].split(','),
      validLabels = /^(data|css):/,
      attr = {
        method: matchParams[0].match(validLabels) ?  matchParams[0].split(':')[0] : 'attr',
        property: matchParams.shift().replace(validLabels,'')
      },
      regexFlags = 'ig',
      regex = new RegExp(matchParams.join('').replace(/^\s+|\s+$/g,''), regexFlags);
    return regex.test(jQuery(elem)[attr.method](attr.property));
  }

  $.query_string_to_hash = function(qs) {
    qs = qs && qs.match(/\?.*$/)[0];

    if (!qs) return {};
      
    var params = {},
        regex  = /[?&]?([^=]+)=([^&]*)/g,
        tokens, key, val;

    qs = qs.split('+').join(' ');

    while (tokens = regex.exec(qs)) {
      key = decodeURIComponent(tokens[1]);
      val = decodeURIComponent(tokens[2]);

      if(/\[\]$/.test(key)) {
        if (!params[key]) params[key] = [];
        params[key].push(val);
      } else {
        params[key] = val;
      }
    }
    return params;
  }

  $.fn.query_hash = function() {
    return $.query_string_to_hash(
      this.attr('href') || this.attr('action')
    );
  }

  $.query = $.query_string_to_hash(document.location.search);

  $.html5 = function() { return typeof window.JSON != 'undefined'; }();

  _.mixin({
    clean: function(obj) {
      _.each(obj, function(val, key) {
        if (!val && val != false) {
          delete obj[key];
        }
      });
      return obj;
    }
  });

  $.submit_with_query = function(remote, options) {
    if (!options) options = {};

    var form = options.form, query, target;

    if (form) {
      options.url      = options.url      || form.attr('action');
      options.dataType = options.dataType || form.attr('data-type');
    }

    _($.query).clean();

    if (true) { // if (remote) {
      target = (form || $.event);

      target.trigger('submit_with_query:before');

      $.ajax({
        url: options.url || window.location.pathname,
        dataType: options.dataType || 'script',
        data: $.param($.query),
        success: function (data, status, xhr) {
          target.trigger('submit_with_query:success', [data, status, xhr]);
        },
        complete: function (xhr) {
          target.trigger('submit_with_query:complete', xhr);
        },
        error: function (xhr, status, error) {
          target.trigger('submit_with_query:failure', [xhr, status, error]);
        }
      });
    } else {
      window.location = path + '?' + $.param($.query);
    }
  }

  /*
   *
   */
  $('form#user_search_form').live('submit', function(e) {
    e.preventDefault();
    $.submit_with_query(true);
  });

  $('form#user_search_form #search').live('change', function(e) {
    var v = $(this).val();
    if (v) {
      $.extend($.query, {'search': v });
    } else {
      delete $.query['search'];
    }
  });

  $.fn.scope_select_defaults = function() {
    return this.each(function(i, el) {
      $.each(el.attributes, function(i, attr) {
        // default params are stored in the form as data-query-n
        if (match = attr.name.match(/^data-query-(.*)$/)) {

          // if query doesn't already have this attribute set...
          if (!$.query[match[1]]) {
            // set it
            $.query[match[1]] = attr.value;

            // and update the form manually to reflect the change
            $('form.scope-selects [name='+match[1]+']').val(attr.value);
          }
        }
      });
    })
  }

  $('form.scope-selects a[rel=clear]').live('click', function(e) {
    e.preventDefault();

    var form = $(this).closest('form');

    $('input[type=text], select', form).val('');
    $('input[type=checkbox]', form).attr('checked', false);

    $.query = {};

    form.scope_select_defaults();

    form.trigger('e9:scope-selects:clear');

    $.submit_with_query(form.attr('data-remote'), { form: form }); 
  });

  $.fn.scope_select = function() {
    function get_key(el) {
      return el.attr('data-scope') || el.attr('name');
    }

    return this.each(function(i, el) {
      el = $(el);

      if (!el.attr('name')) return;

      if (!el.data('scope_select')) { 
        el.data('scope_select', true);

        var do_change = function() {

          var 
          $this = $(this),
          name  = get_key($this),
          value = $this.val(),
          form  = $('form.scope-selects');

          if ($this.is('input:radio')) {
            $('input[name="'+$this.attr('name')+'"]').each(function(i, el) {
              delete $.query[get_key($(el))];
            });
          }

          if ($this.is('input:checkbox')) {
            if ($this.attr('disabled')) {
              $this.attr('checked', false);
            }

            if (!$this.is(':checked')) {
              value = false;
            }
          }

          // this is duplicate when query is cleaned on send
          if (value) {
            $.query[name] = value;
          } else {
            delete $.query[name];
          }

          $.event.trigger('scope-select:change:' + name, value);

          $.submit_with_query(form.attr('data-remote'), { form: form }); 
        }

        // Initialize the fields from $.query
        if (el.is(':radio') || el.is(':checkbox')) {
          el.attr('checked', function(n, v) {
            var cVal = $.query[get_key(el)] || '';
            return el.val() == cVal;
          });
        } else {
          el.val($.query[get_key(el)] || '');
        }

        //
        if (el.is('input[type=text]')) {
          el.bind('keyup_submit', do_change);
        } else {
          el.change(do_change);
        }
      }
    });
  }

  var _f;(_f = function() {
    $(
      'form.scope-selects select, '               +
      'form.scope-selects input[type=radio], '    +
      'form.scope-selects input[type=hidden], '   +
      'form.scope-selects input[type=text], '     +
      'form.scope-selects input[type=checkbox], ' +
      'input.scope-selects'
    ).scope_select();
  })();
  $(document).ajaxComplete(_f);

  $.fn.anytime = function(options) {
    if (!this.attr('id') || this.attr('data-date-picker')) return;

    options = $.extend({format: '%m/%d/%Y'}, options);

    $(this)
      .attr('data-date-picker', true)
      .AnyTime_noPicker()
      .AnyTime_picker(options);
  }

  /** datepicker behavior for dates */
  $('input.date-picker').live('focus', function() { 
    $(this).anytime();
  });

  /** datepicker behavior for times */
  $('input.time-picker').live('focus', function() { 
    $(this).anytime({format: "%m/%d/%Y %I:%i %p"});
  });

  /** "clear" button for date fields */
  $('.datetime-picker-clear').live('click', function(e) {
    e.preventDefault();

    // Clears .(date|time)-picker fields under
    // our .field div and triggers the change event.
    // I don't recall why we have to trigger change, but I'm
    // sure it has something to do with AnyTime
    $(this)
      .parents('.field')
        .find('.date-picker, .time-picker')
        .val('')
        .change()
    ;
  });


  /*
   * Hack to enable [placeholder] in old browsers
   */
  if (!('placeholder' in document.createElement('input'))) {
    $('[placeholder]')
      .live('focus', function() {
        var input = $(this);
        if (input.val() == input.attr('placeholder')) {
          input.val('');
          input.removeClass('placeholder');
        }
      })
      .live('blur', function() {
        var input = $(this);
        if (input.val() == '' || input.val() == input.attr('placeholder')) {
          input.addClass('placeholder');
          input.val(input.attr('placeholder'));
        }
      })
    ;

    $('form').submit(function() {
      $(this).find('[placeholder]').each(function() {
        var input = $(this);
        if (input.val() == input.attr('placeholder')) {
          input.val('');
        }
      })
    });
  }

  $('select.url-select').live('change', function() {
    location.href = $(this).val();
  });

  /* 
   * note that forms WITHOUT the validate class have their functionality 
   * set up in jquery.rails.js 
   */
  $('form.validate[data-remote]').livequery("submit", function (e) {
    e.preventDefault();

    var 
    $f = $(this), 
    message = $f.attr('data-error-message') || 
        "There was a problem with the form submission, please check below for errors";

    // if the validator has not been defined
    if (!$f.data('validator')) {

      // define it, including an ajax submit handler
      $f.validate({
        onclick: false,
        onfocusout: false,
        onkeyup: false,
        errorClass: 'field_with_errors',
        errorElement: 'div',
        invalidHandler: function(f, v) {
          $('.flash-messages').alertMessage(message);

          $('html, body').animate({ 
            scrollTop: $f.offset().top - 10
          }, 350);
        },
        submitHandler: function(v) {
          $f.callRemote();
        }
      });

      // then re-submit, to the now validated form
      $f.submit();
    }
  });
});
