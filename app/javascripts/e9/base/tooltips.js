;(function($) {
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
  var tooltips = $.e9.tooltips = function(options, overrides) {
    options = options || {};

    var 

    defaults = {
      style: { tip: { corner: false } },
      position: { my: 'top left', at: 'top right', adjust: { x: -1, y: -1 } },
      hide: { fixed: true, delay: 75 },
      show: { delay: 25, solo: true }
    },

    slideshow_defaults = {
      position: { my: 'top right', at: 'bottom right', adjust: { y: 10 } }
    },
    
    image_defaults = {
      position: { target: 'mouse', my: 'bottom left', at: 'top right', adjust: { y: -5, x: 5 } }
    },

    help_defaults = {
      position: { my: 'top left', at: 'top right' },
      show: { 
        event: 'click', 
        solo: true 
      },
      hide: {
        event: 'mouseleave',
        'fixed': true,
        'delay': 250
      }
    }

    tooltips.options = function(type) {
      return $.extend(true, {}, tooltips.options[type || 'defaults']);
    }

    tooltips.options.defaults  = $.extend({}, defaults, options.defaults);
    tooltips.options.slideshow = $.extend({}, tooltips.options.defaults, slideshow_defaults, options.slideshow);
    tooltips.options.image     = $.extend({}, tooltips.options.defaults, image_defaults, options.image);
    tooltips.options.help      = $.extend({}, tooltips.options.defaults, help_defaults, options.help);
  }

  $.fn.tooltips = function(type, overrides) {

    return this.live('mouseover click', function(e) {
      var tip, content, options,
          el = $(this);

      if (!el.data('e9_tooltips')) {

        el.data('e9_tooltips', true);
        
        tip = el.next('.tooltip');

        if (tip.length) {
          e.preventDefault();

          options = tooltips.options(type);
          options.content = options.content || {};

          $.extend(options, overrides);

          $.extend(options.content, {
            text: tip
          });

          el.qtip(options).mouseover();
        }
      }

    })
  }

  $.fn.helpTooltips = function(e) {

    $(this).not('.tip-inited').each(function(i, el) {

      var $el = $(el), title, content;

      $el.addClass('tip-inited');

      title   = $el.attr('data-title') || 'Help';

      content = el.attributes.title.value
                  .replace(/\n/gi, '<br />')
                  .replace(/\t/gi, '&nbsp;&nbsp;&nbsp;&nbsp;');

      opts = $.extend({}, tooltips.options.help, { 
        content: { 
          title: { text: title, button: true },
          text: content
        }
      });

      $el
        .bind('click mouseover', function(e) {
          e.preventDefault();
          e.stopPropagation();
        })
        .qtip(opts)
    });
  }

  $(function() {
    $.e9.tooltips();

    $('.help[rel=tooltip]').live('mouseover', function() {
      $(this).helpTooltips();
    });

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

    $('#slide-dashboard a.action-link, .content-action-links a.action-link').tooltips('slideshow');

    $('a.do-select').tooltips('image');

    $('.click[rel=tooltip]').tooltips('help', {
      show: { event: 'click', solo: true },
      content: { title: { text: '&nbsp;', button: true } }
    });

    $('.tool-button[rel=tooltip]').tooltips('help', {
      style: { tip: { corner: false } },
      position: { my: 'top right', at: 'top left' },
      hide: { fixed: true, delay: 50, inactive: 1500 },
      show: { delay: 15, solo: true }
    });
  });
})(jQuery);
