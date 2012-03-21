;(function($) {
  window.e9 = window.e9 || {};

  var 
  options, 

  slides = window.e9.slides = function(obj) {
    options = slides.options = _.defaults(slides.options || {}, obj, defaults);
    unbind_hashchange();
    bind_hashchange();
  },

  events = slides.events = {
    load  : 'e9_slides_load',
    init  : 'e9_slides_init'
  },

  loaded = slides.loaded = {},

  defaults = {
    body_selector     : '#slide',
    comments_selector : '#slide-comments',
    complete          : function(slide) {
      document.title = slide.page_title;
      render_api.body(slide);
      render_api.comments(slide);
      render_api.regions(slide);
    }
  },

  render_api = slides.render_api = {
    body : function(slide) {
      if (slide.html && slide.layout) {
        $(options.body_selector).html(
          JST[slide.layout]($.extend({}, slide, slide.html))
        );
      }
    },

    comments : function(slide) {
      if (slide.html) {
        $(options.comments_selector).html(slide.html.comments || '');
      }
    },

    regions : function(slide) {
      if (slide.html) {
        $.each(slide.html.regions, function(key, val) {
          $('#'+key).html(val);
        });
      }
    }
  },

  init = function(opts) {
    slides(opts);
    do_hashchange();
    $.event.trigger(events.init);
  },

  load = function(slide) {
    var params = {}, success = function(slide) {
      if (!loaded[slide.param]) loaded[slide.param] = slide;

      slides.current = slide;

      /*
       * If the param of the loaded slide is different than
       * the param asked for, then the slide was not found or
       * otherwise inaccessible.  Unbind hashchange and
       * reset the hash to the param of the new slide.
       */
      if (slide.param != params.id) {
        set_hash_without_change(slide.param);
      }

      /* then call the load complete callback */
      options.complete(slide);

      /* trigger slide loaded */
      $.event.trigger(events.load, [slide]);
    }

    if (loaded[slide]) {
      success(loaded[slide]);
    } else {
      // let the JSON know we want HTML partials rendered
      params.id   = slide;
      params.html = 1;

      $.ajax({
        url: slides.options.url,
        method: 'GET',
        dataType: 'json',
        data: params,
        success: success
      });
    }
  },

  do_hashchange = function() {
    if (!window.location.hash) 
      window.location.hash = slides.options.slide;
    else 
      $(window).hashchange();
  },

  unbind_hashchange = function() {
    $(window).unbind('hashchange.e9_slides');
  },

  bind_hashchange = function() {
    $(window).bind('hashchange.e9_slides', function() {
      var hash = window.location.hash;

      if (hash[1] == '!') {
        return;
      } else {
        load(hash.replace(/^#/, ''));
      }
    });
  },

  set_hash_without_change = function(value) {
    unbind_hashchange();
    window.location.hash = value;
    bind_hashchange();
  }

  $(function() {
    $('#slideshow-load').each(function() {
      init({
        slide : $(this).attr('data-slide'),
        url   : $(this).attr('data-url')
      });
    });
  });
}(jQuery));
