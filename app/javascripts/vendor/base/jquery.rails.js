jQuery(function ($) {
    var csrf_token = $('meta[name=csrf-token]').attr('content'),
        csrf_param = $('meta[name=csrf-param]').attr('content'),
        rails;

    $.fn.extend({
        /**
         * Triggers a custom event on an element and returns the event result
         * this is used to get around not being able to ensure callbacks are placed
         * at the end of the chain.
         *
         * TODO: deprecate with jQuery 1.4.2 release, in favor of subscribing to our
         *       own events and placing ourselves at the end of the chain.
         */
        triggerAndReturn: function (name, data) {
            var event = new $.Event(name);
            this.trigger(event, data);

            return event.result !== false;
        },

        /**
         * Handles execution of remote calls firing overridable events along the way
         */
        callRemote: function (e) {
            var el      = this,
                data    = el.is('form') ? el.serializeArray() : [],
                method  = el.attr('data-method') || el.attr('method') || 'GET',
                url     = el.attr('action') || el.attr('href');

            if(e && el.is('form') && $(e.target).is(":submit")) {
              data.push({ name: e.target.name, value: e.target.value });
            }

            var type, ext = url.split('.').pop();
            
            if (ext == 'json') {
              type = 'json';
            } else {
              type = el.attr('data-type') || 'script';
            }

            if (url === undefined) {
              throw "No URL specified for remote call (action or href must be present).";
            } else {
                if (el.triggerAndReturn('ajax:before')) {
                    $.ajax({
                        url: url,
                        data: data,
                        dataType: type,
                        type: method.toUpperCase(),
                        beforeSend: function (xhr) {
                            xhr.setRequestHeader('X-CSRF-Token', csrf_token);
                            $('input[type=submit]', el).attr('disabled','disabled');
                            el.trigger('ajax:loading', xhr);
                        },
                        success: function (data, status, xhr) {
                            el.trigger('ajax:success', [data, status, xhr]);
                        },
                        complete: function (xhr) {
                            el.trigger('ajax:complete', xhr);
                            $('input[type=submit]', el).removeAttr('disabled').removeClass('ui-state-hover').blur();
                        },
                        error: function (xhr, status, error) {
                            el.trigger('ajax:failure', [xhr, status, error]);
                        }
                    });
                }

                el.trigger('ajax:after');
            }
        }
    });

    /**
     *  confirmation handler
     */
    $('a[data-confirm],input[data-confirm]').live('click', function () {
        var el = $(this);
        if (el.triggerAndReturn('confirm')) {
            if (!confirm(el.attr('data-confirm'))) {
                return false;
            }
        }
    });

    /**
     * New feature of rails 3.0.10?  All js xhr just have CSRF token header?
     */
    $.ajaxSetup({
      beforeSend: function(xhr, options) {
        if (options.dataType == 'script' || options.dataType == 'json') {
          xhr.setRequestHeader('X-CSRF-Token', csrf_token);
        }
      }
    });

    /**
     * remote handlers
     */
    
    /* note this is being added later, after validate js is added  */
    $('form:not(.validate)[data-remote]').livequery("submit", function (e) {
        e.preventDefault();
        $(this).callRemote();
    });

    /* FIXME fix conflict with jquery.validate so I can take off this not(.validate) filter */
    $('form:not(.validate)[data-remote] :submit').live('click', function (e) { 
       $(this.form).callRemote(e); 
       return false; 
    });

    $('a[data-remote],input[data-remote]').live('click', function (e) {
        e.preventDefault();
        $(this).callRemote();
    });

    $('a[data-method]:not([data-remote])').live('click', function (e){
        var link = $(this),
            href = link.attr('href'),
            method = link.attr('data-method'),
            form = $('<form method="post" action="'+href+'"></form>'),
            metadata_input = '<input name="_method" value="'+method+'" type="hidden" />';

        if (csrf_param != null && csrf_token != null) {
          metadata_input += '<input name="'+csrf_param+'" value="'+csrf_token+'" type="hidden" />';
        }

        form.hide()
            .append(metadata_input)
            .appendTo('body');

        e.preventDefault();
        form.submit();
    });

    /**
     * disable-with handlers
     */
    var disable_with_input_selector = 'input[data-disable-with]';
    var disable_with_form_selector = 'form[data-remote]:has(' + disable_with_input_selector + ')';

    $(disable_with_form_selector).live('ajax:before', function () {
        $(this).find(disable_with_input_selector).each(function () {
            var input = $(this);
            input.data('enable-with', input.val())
                 .attr('value', input.attr('data-disable-with'))
                 .attr('disabled', 'disabled');
        });
    });

    $(disable_with_form_selector).live('ajax:after', function () {
        $(this).find(disable_with_input_selector).each(function () {
            var input = $(this);
            input.removeAttr('disabled')
                 .val(input.data('enable-with'));
        });
    });
});

