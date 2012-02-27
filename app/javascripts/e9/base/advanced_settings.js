(function ($, window) {

  var default_options = {
    showText: 'Show Advanced Settings',
    hideText: 'Hide Advanced Settings',
    showFn: function(target) { target.slideDown('fast') },
    hideFn: function(target) { target.slideUp('fast') },
    innerSel: '.fields',
    forceHide: true
  },

  init = function(options) {
    return this.each(function(i, el) {

      el      = $(el);
      options = $.extend({}, default_options, options);

      if (!el.data('advanced_settings')) {
        var actions, target = el.find(options.innerSel);

        if (options.forceHide) { target.hide(); }

        actions = '<div class="action-links">' +
                    '<a href="#">' + 
                      (target.is(':hidden') ? options.showText : options.hideText) +
                    '</a>' +
                  '</div>';

        $(actions).click(function(e) {
          e.preventDefault();

          if (target.is(':hidden')) {
            options.showFn(target);
            $(this).find('a').text(options.hideText);
          } else {
            options.hideFn(target);
            $(this).find('a').text(options.showText);	
          }
        }).insertBefore(target);

        el.data('advanced_settings', options);
      }
    })
  }

  $.fn.advanced_settings = function(options) {
    if (typeof options === 'object' || !options) {
      return init.apply(this, arguments);
    } else {
      $.error('Method '+ options +' does not exist');
    }    
  }

})(jQuery, this);
