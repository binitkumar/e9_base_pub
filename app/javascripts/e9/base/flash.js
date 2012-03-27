/*
 * NOTE: this depends on doTimeout
 */
;(function($) {
  window.e9 = window.e9 || {};

  var 

  flash = window.e9.flash = {},

  options,

  DoTimeoutKey    = 'flash_message',
  XhrNoticeHeader = 'X-Flash-Notice',
  XhrAlertHeader  = 'X-Flash-Alert',

  events = flash.events = {
    show : 'e9_flash:show',
    hide : 'e9_flash:hide',
    init : 'e9_flash:init'
  },

  defaults = {
    timeout       : 6000,
    duration      : 350,
    easing        : 'swing',
    selector      : '.flash-messages',
    default_class : 'alert',
    insert        : function(el) { el.prependTo('body'); },

    /*
     * The default hide animation works with the default style, which
     */
    hide : function(el, callback) {
      var m = el.find('.flash'), h, body;

      if (m.length == 0) {
        if (callback) callback();
      } else {
        h = m.outerHeight(), body = $('body');

        m.animate({ top: h * -1 }, {
          duration: flash.options.duration, 
          easing: flash.options.easing, 
          complete: callback,
          step: function(p) {
            var t = h + Math.round(p);

            if (Modernizr.touch) {
              body.css('padding-top', t);
            } else {
              el.height(t);
            }
          }
        });
      }
    },

    show : function(el, callback) {
      // slide down
      var m = el.find('.flash'), body, h;

      if (m.length == 0) {
        if (callback) callback();
      } else {
        // move the flash off screen and show the container
        m.css('top', -9999)
        el.show();

        // get the drawn height
        h = m.outerHeight();

        body = $('body');

        // then animate the body's padding and top of the flash
        m.css('top', h * -1).animate({ top: 0 }, {
          duration: flash.options.duration, 
          easing: flash.options.easing, 
          complete: callback,
          step: function(p) {
            var t = h + Math.round(p);

            if (Modernizr.touch) {
              body.css('padding-top', t);
            } else {
              el.height(t);
            }
          }
        });
      }
    }
  },

  handlers = {
    click: function(e) {
      flash.hide();
    },

    ajax_complete: function(e, xhr) {
      var msg;

      if (xhr == undefined) {
        flash.hide();
      } else if (msg = xhr.getResponseHeader(XhrAlertHeader)) {
        flash.notify.alert(msg);
      } else if (msg = xhr.getResponseHeader(XhrNoticeHeader)) {
        flash.notify.notice(msg);
      }
    }
  },

  timeout = {
    clear: function() {
      $.doTimeout(DoTimeoutKey);
    },

    start: function(callback) {
      timeout.clear();
      $.doTimeout(DoTimeoutKey, options.timeout, callback);
    }
  }

  $.extend(flash, {
    init: function(opts) {
      options = flash.options = _.defaults(flash.options || {}, opts, defaults);

      flash.element = $(options.selector);

      if (flash.element.length) {
        flash.element.hide().detach();
      } else {
        flash.element = $('<div '+options.selector+' />');
      }

      flash.element.click(handlers.click);

      options.insert(flash.element);

      if (flash.has_messages()) flash.show_with_timeout();

      $(document).ajaxComplete(handlers.ajax_complete);

      $.event.trigger(events.init, [flash]);
    },

    notify: function(message, css_class) {
      if (!message) return;

      flash.hide(function() {
        flash.element.empty();

        $('<div class="flash" />')
          .addClass(css_class || options.default_class)
          .html(message)
          .appendTo(flash.element);

        flash.show_with_timeout();
      });
    },

    show: function(callback) {
      timeout.clear();
      options.show(flash.element, callback);
      $.event.trigger(events.show, [flash]);
    },

    hide: function(callback) {
      timeout.clear();
      options.hide(flash.element, callback);
      $.event.trigger(events.hide, [flash]);
    },

    show_with_timeout: function() {
      flash.show(function() { timeout.start(flash.hide) });
    },

    has_messages: function() {
      return flash.element.children().length > 0;
    },

    define_notification: function(type) {
      flash.notify[type] = function(message) { flash.notify(message, type) }
    }
  });

  flash.define_notification('alert');
  flash.define_notification('notice');
}(jQuery));
