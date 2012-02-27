;jQuery(function($) {
  $.slide_paginate = function(page, force) {
    if (page === undefined || page === 0) return;
    if (!force && $.slide_paginate.animating) return;
    $.slide_paginate.animating = true;

    var $thumbs  = $('.slide-pagination-thumbs'),
        per_page = parseInt($thumbs.attr('data-per-page')),
        cur_page = parseInt($thumbs.attr('data-page')),
        pages    = parseInt($thumbs.attr('data-pages'));

    if ($thumbs.length == 0) {
      $.slide_paginate.animating = false;
      return;
    }

    if (typeof(page) === 'boolean') {
      if (page) {
        page = cur_page + 1;
        if (page > pages) {
          $.slide_paginate.animating = false;
          return;
        }
      } else {
        page = cur_page - 1;
        if (page <= 0) {
          $.slide_paginate.animating = false;
          return;
        }
      }
    }

    var $list = $thumbs.find("li"),
        $el   = $($list[per_page * (page - 1)]);

    // notify the slide buttons
    $.event.trigger('slide_selector', [
      // should prev button be enabled?
      page - 1 > 0,

      // should next button be enabled?
      page + 1 <= pages
    ]);

    $el.closest('ul').animate({ left: $el.position().left * -1 }, 250, function() {
      $thumbs.attr('data-page', page);
      $.slide_paginate.animating = false;
    });
  }

  $('#slide-selector .slide-pagination-next a')
    .bind('click', function(e) {
      e.preventDefault();
      $.slide_paginate(true);
    })
    .bind('slide_selector', function(e, prev, next) {
      if (next) {
        $(this).attr('href', '#!next');
      } else {
        $(this).removeAttr('href');
      }
    })
  ;

  $('#slide-selector .slide-pagination-prev a')
    .live('click', function(e) {
      e.preventDefault();
      $.slide_paginate(false);
    })
    .bind('slide_selector', function(e, prev, next) {
      if (prev) {
        $(this).attr('href', '#!prev');
      } else {
        $(this).removeAttr('href');
      }
    })
  ;


  /* stores the url of the current slideshow, set in slideshow index.html */
  var 
  slideshow_url = "",

  _slide_load = function(slide) {
    var params = {};

    params.id = slide;

    // let the JSON know we want HTML partials rendered
    params.html = 1;

    $.ajax({
      url: slideshow_url,
      method: 'GET',
      dataType: 'json',
      data: params,
      success: function(data, status, xhr) {
        /*
         * If the param of the loaded slide is different than
         * the param asked for, then the slide was not found or
         * otherwise inaccessible.  Unbind hashchange and
         * reset the hash to the param of the new slide.
         */
        if (data.param != params.id) {
          set_hash_without_change(data.param);
        }

        /* then call the load complete callback */
        $.slide_load_complete(data, status, xhr)
      }
    });
  },

    /* loads the slide specified by location.hash */
  slideshow_hashchange = function(options) {
    var hash = window.location.hash;

    if (hash[1] == '!') {
      return;
    } else {
      $.slide_load(hash.replace(/^#/, ''));
    }
  },

  bind_hashchange = function() {
    $(window).bind('hashchange', slideshow_hashchange);
  },

  set_hash_without_change = function(value) {
    $(window).unbind('hashchange');
    window.location.hash = value;
    bind_hashchange();
  }

  /*
   * Set the base url for the slideshow, then if the hash is set, e.g.
   * in the case of a direct link to a slide in a slideshow, simply
   * fire hashchange.  If it is not set, set the hash to be the
   * currently loaded resource (probably slide 1 in the show)
   */
  $.slideshow_load = function(params) {
    bind_hashchange();

    slideshow_url = params.url;

    if (!window.location.hash) {
      window.location.hash = params.slide;
    } else {
      $(window).hashchange();
    }
  }

  $.slide_load = function(slide) {
    var params = {};

    params.id = slide;

    // let the JSON know we want HTML partials rendered
    params.html = 1;

    $.ajax({
      url: slideshow_url,
      method: 'GET',
      dataType: 'json',
      data: params,
      success: function(data, status, xhr) {
        /*
         * If the param of the loaded slide is different than
         * the param asked for, then the slide was not found or
         * otherwise inaccessible.  Unbind hashchange and
         * reset the hash to the param of the new slide.
         */
        if (data.param != params.id) {
          set_hash_without_change(data.param);
        }

        /* then call the load complete callback */
        $.slide_load_complete(data, status, xhr)
      }
    });
  }

  /*
   * Callback for a slide's JSON load
   */
  $.slide_load_complete = function(slide) {

    $("#slide-selector #slide_thumb_"+slide.id)
      .closest('li')
      .addClass('current')
      .siblings()
      .removeClass('current')
    ;

    $.slide_paginate(slide.page, true);

    if (slide.html) {
      if (slide.layout) {
        $('#slide').html(
          // extending html so it can overwrite normal JSON
          JST[slide.layout](
            $.extend({}, slide, slide.html)
          )
        );
      }

      $('#slide-comments').html(slide.html.comments || '');

      document.title = slide.page_title;

      $.each(slide.html.regions, function(key, val) {
        $('#'+key).html(val);
      });
    }
  }
});
