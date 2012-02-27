;jQuery(function($) {
  /*
   * NOTE: this depends on doTimeout
   */

  $.e9 = $.e9 || {};

  $.extend($.e9, {
    flash: {
      timeout  : 3000,
      speed    : 300,
      selector : '.flash-messages'
    }
  });

  if (!$.fn.hasOwnProperty('flashHide')) {
    /** method to animate flash hide */
    $.fn.flashHide = function(callback) {
      // simple fadeout
      //$(this).fadeOut(callback);

      // slide up
      this.animate({ top: this.outerHeight() * -1 }, $.e9.flash.speed, 'linear', callback);

      // Simply passes control to the callback if it is passed, effectively skipping the hide.  
      // If callback is otherwise true (the click event is passed by default) then it will
      // fade out.
      //if (typeof callback == 'function') {
        //callback.apply(this);
      //} else if (callback) {
        //$(this).fadeOut($.e9.flash.speed);
      //}
    }
  }

  if (!$.fn.hasOwnProperty('flashShow')) {
    /** method to animate flash show */
    $.fn.flashShow = function(callback) {
      // slide down
      this.css('top', -9999).show();
      var h = this.outerHeight();
      this
        .css('top', h * -1)
        .animate({ top: 0 }, $.e9.flash.speed, 'linear', callback)
      ;
    }
  }

  $.fn.alertMessage = function(message, css_class) {
    $(this).flashHide(function() {
      if(message != null && message != undefined) {
        var $this = $(this);
        $this
          .hide()
          .html('<div class="'+(css_class || 'alert')+'">'+message+'</div>')
          .flashShow(function() {
            $.doTimeout('flash_message', $.e9.flash.timeout, function() {
              $this.flashHide();
            });
          })
        ;
      }
    });
  }


  $($.e9.flash.selector)
    // hide initially, regardless
    .hide()

    .hover( 
      function(){ $(this).addClass('hover'); }, 
      function(){ $(this).removeClass('hover'); }
    )

    .bind('e9:flash', function(e, message, css_class) {
      $(this).alertMessage(message, css_class);
    })

    // on click clear the flash_message timeout and hide
    .click(function(e) { 
      $.doTimeout('flash_message');
      $(this).flashHide(e);
    })

    // On ajaxComplete, hide if no xhr, otherwise if xhr and the headers 
    // contain a custom flash header (a message), hide then set the
    // timeout to show the message.
    .ajaxComplete(function(e, xhr) {
      var $el = $(this), msg;
      if (xhr == undefined) {
        $el.hide();
      } else if (msg = xhr.getResponseHeader('X-Flash-Alert')) {
        $el.hide().alertMessage(msg, 'alert');
      } else if (msg = xhr.getResponseHeader('X-Flash-Notice')) {
        $el.hide().alertMessage(msg, 'notice');
      }
    })

    // On load if there is a message, show it and hide after a timeout.
    .each(function(i, el) {
      var $el = $(el);
      if ($el.children().length > 0) {
        $el.flashShow(function() {
          $.doTimeout('flash_message', $.e9.flash.timeout, function() {
            $el.flashHide();
          });
        });
      }
    })
  ;
});
