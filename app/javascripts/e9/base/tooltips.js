;jQuery(function($) {
  $.e9 = $.e9 || {};

  /**
   * Set up system tooltips
   *
   * Arguments
   * =========
   *
   * Accepts 4 hash arguments of qtip options, optionally:
   *
   * options.defaults  -- The base options from which all others are extended
   * options.slideshow -- Overrides for slideshow tooltips
   * options.image     -- Overrides for image title tooltips
   * options.help      -- Overrides for help tooltips
   *
   * Example invocation:
   *
   *   $.e9.tooltips({
   *     defaults: {
   *       style: { classes: 'ui-tooltip-shadow', tip: { corner: false } },
   *       position: { my: 'top left', at: 'top right' }
   *     },
   *     slideshow: {
   *       position: { my: 'top left', at: 'bottom left' }
   *     }
   *   });
   *
   *  As a result of this call
   *
   *  - all tooltips will have the 'ui-tooltip-shadow'  class.
   *  - standard action link tooltips will be positioned top left / top right
   *  - slideshow links will be positioned top left / bottom left
   *
   *  All tooltip types have their own positioning and must be overridden
   *  individually.  All other options from "defaults" will fall through,
   *  with the exception being that "hide" is false by default for help
   *  tooltips.  See defaults below.
   */
  $.e9.tooltips = function(options) {
    options = options || {};
    
    var 

    defaults = {
      style: { tip: { corner: false } },
      position: { my: 'top left', at: 'top right', adjust: { x: -1, y: -1 } },
      hide: { fixed: true, delay: 75 },
      show: { delay: 25, solo: true }
    },

    slideshow_defaults = {
      position: { my: 'top left', at: 'bottom left', adjust: { y: 10 } }
    },
    
    image_defaults = {
      position: { target: 'mouse', my: 'bottom left', at: 'top right', adjust: { y: -5, x: 5 } }
    },

    help_defaults = {
      position: { my: 'top left', at: 'top right' },
      hide: false
    },

    default_options   = $.extend({}, defaults, options.defaults),
    slideshow_options = $.extend({}, default_options, slideshow_defaults, options.slideshow),
    image_options     = $.extend({}, default_options, image_defaults, options.image),
    help_options      = $.extend({}, default_options, help_defaults, options.help),

    tooltips = function(el, options) {
      var $el = $(el), $tip = $el.next('.tooltip');

      if ($tip.length) {
        options.content = options.content || {};

        $.extend(options.content, {
          text: $tip
        });

        $el.click(function(e){e.preventDefault()})
           .qtip(options);
      }
    }

    $.fn.helpTooltips = function(e) {
      return this.each(function(i, el) {
        el = $(el);

        if (!el.data('qtip')) {
          var 

          title = el.attr('data-title') || 'Help',

          opts  = $.extend({}, help_options, { 
            content: { title: { text: title, button: true } }
          });

          el
            .click(function(e){ if(e) e.preventDefault() })
            .qtip(opts).attr('title', function(i, val) {
              val = val.replace(/\n/gi, '<br />');
              val = val.replace(/\t/gi, '&nbsp;&nbsp;&nbsp;&nbsp;');

              return val;
            })
            .mouseover()
          ;
        }
      })
    }

    /*
     * Ajax tooltips
     */
    var _f;(_f=function() {
      $('.left-block a.action-link').each(function(i, el) {
        tooltips(this, default_options);
      });

      $('#slide-dashboard a.action-link').each(function(i, el) {
        tooltips(this, slideshow_options);
      });

      $('a.do-select').each(function(i, el) {
        tooltips(this, image_options);
      });

      $('.click[rel=tooltip]').each(function(i, el) {
        tooltips(el, $.extend({}, help_options, {
          show: { event: 'click', solo: true },
          content: { title: { text: '&nbsp;', button: true } }
        }));
      });

      $('.tool-button[rel=tooltip]').each(function(i, el) {
        tooltips(el, $.extend({}, help_options, {
          style: { tip: { corner: false } },
          position: { my: 'top right', at: 'top left' },
          hide: { fixed: true, delay: 50, inactive: 1500 },
          show: { delay: 15, solo: true }
        }));
      });

      $('img[title]').qtip(image_options);

      $('.img[rel=tooltip]').each(function() {
          var 
          thumb = $(this).attr('data-src'),
          content = $('<img />', { src: thumb });
          
          $(this).qtip({
             content: {
                text: content,
                title: { text: $(this).attr('data-title') || 'Help' }
             },
             position: {
                my: 'left bottom',
                at: 'bottom right'
             },
             style: defaults.style
          });
       });
    })();
    $(document).ajaxComplete(_f);

    /*
     * "help" tooltips, no need for Ajax reload
     */
    $('.help[rel=tooltip]').live('mouseover click', function() {
      $(this).helpTooltips();
    });
  }

});
