/*
 * NOTE: this depends on doTimeout
 */
;(function($) {
  window.e9 = window.e9 || {};

  var 
  options,

  flash = window.e9.flash = {
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

      if (flash.has_messages) flash.show();

      $(document).ajaxComplete(handlers.ajax_complete);

      $.event.trigger(events.init, [flash]);
    },

    notify: function(message, css_class) {
      if (!message) return;

      flash.element.empty();

      flash.hide(function() {
        $('<div />')
          .addClass(css_class || options.default_class)
          .html(message)
          .appendTo(flash.element);

        render();
      });
    },

    show: function(callback) {
      timeout.clear();
      options.show(flash.element, callback);
    },

    hide: function(callback) {
      timeout.clear();
      options.hide(flash.element, callback);
    },

    has_messages: function() {
      return flash.element.children().length > 0;
    },

    define_notification: function(type) {
      flash.notify[type] = function(message) { flash.notify(message, type) }
    },
  }

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
    timeout       : 3000,
    speed         : 300,
    selector      : '.flash-messages',
    insert        : function(el) { el.prependTo('body'); },
    default_class : 'alert',

    hide: function(el, callback) {
      // simple fadeout
      el.fadeOut(callback);

      // slide up
      // el.animate({ top: el.outerHeight() * -1 }, flash.options.speed, 'linear', callback);

      // Simply passes control to the callback if it is passed, effectively skipping the hide.  
      // If callback is otherwise true (the click event is passed by default) then it will
      // fade out.
      //if (typeof callback == 'function') {
        //callback.apply(this);
      //} else if (callback) {
        //$(this).fadeOut($.e9.flash.speed);
      //}
    },

    show: function(el, callback) {
      // simple fadeout
      el.fadeIn(callback);

      // slide down
      // el.css('top', -9999).show();
      // var h = el.outerHeight();
      // el 
      //   .css('top', h * -1)
      //   .animate({ top: 0 }, flash.options.speed, 'linear', callback)
      // ;
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
  },

  render = function() {
    flash.show(function() { timeout.start(flash.hide) });
  }

  flash.define_notification('alert');
  flash.define_notification('notice');

  $(flash.init);

}(jQuery));
