;(function($) {
  window.e9 = window.e9 || {};

  var 
  api = 'e9_carousel',
  carousel = window.e9.carousel = {
    api    : api,
    events : {
      change : api+':change'
    }
  },
 
  defaults = {
    thumb_selector : '.slide-pagination-thumbs',
    easing         : 'swing',
    speed          : 350
  },

  methods = {
    init : function(options) {
      options = $.extend({}, defaults, options);

      return this.each(function() {
        var el = $(this), thumbs = $(options.thumb_selector, el);

        if (!el.data(api) && thumbs.length > 0) {
          el.data(api, {
            list      : $('ul', el),
            per_page  : Number(thumbs.attr('data-per-page')),
            page      : Number(thumbs.attr('data-page')),
            pages     : Number(thumbs.attr('data-pages')),
            speed     : options.speed,
            easing    : options.easing,
            animating : false
          });

          function clickHandler(d) {
            return function(event) {
              event.preventDefault();
              el[api]('paginate', d);
            }
          }

          $('.slide-pagination-next a', el).bind('click', clickHandler(true))
          $('.slide-pagination-prev a', el).bind('click', clickHandler(false))

          el.bind(carousel.events.change, function(e, data) {
            $('.slide-pagination-prev a', this).each(function() {
              if (data.prev) {
                $(this).attr('href', '#!prev');
              } else {
                $(this).removeAttr('href');
              }
            });

            $('.slide-pagination-next a', this).each(function() {
              if (data.next) {
                $(this).attr('href', '#!next');
              } else {
                $(this).removeAttr('href');
              }
            });
          });

          el.bind(e9.slides.events.load, function(e, slide) {
            $("#slide_thumb_" + slide.id, this)
              .closest('li')
              .addClass('current')
              .siblings()
              .removeClass('current')
            ;

            $(this)[api]('paginate', slide.page);
          });
        }
      });
    },

    /**
     * page (boolean) : true/next or false/prev
     * page (number)  : a specific page
     */
    paginate : function(page) {
      // return unless page is passed
      if (page === undefined) return;

      var el = $(this), data = el.data(api);

      // return if we're already on the page
      if (page === data.page) return;

      // if page is a boolean, determine page # of prev or next
      if (typeof page === 'boolean') {
        page = page ? data.page + 1 : data.page - 1;
      } 
      
      // if at this point page is not a number or if it's outside
      // the range of possible pages, return
      if (typeof page !== 'number' || page <= 0 || page > data.pages) {
        return;
      }

      // finally, return if the pagination animation is running, or start
      // the animation process
      if (data.animating) return;
      data.animating = true;

      var li = $('li', data.list).eq(data.per_page * (page - 1));

      // notify the slide buttons
      el.trigger(carousel.events.change, [{
        current : li,
        prev    : page - 1 > 0,
        next    : page + 1 <= data.pages
      }]);

      data.list.animate({left: li.position().left * -1 }, data.speed, data.easing, function() {
        data.animating = false;
        data.page      = page;
      });
    }
  }

  $.fn[api] = function(method) {
    if (methods[method]) {
      return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
    } else if (typeof method === 'object' || !method) {
      return methods.init.apply(this, arguments);
    } else {
      $.error('Method '+  method +' does not exist on '+ api);
    }    
  };

  $(function() {
    $('#slide-selector')[api]();
  });
}(jQuery));
