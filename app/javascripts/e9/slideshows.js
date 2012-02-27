;jQuery(function($) {
  var
    api = 'slideshow',

    defaults = {
      template: '\
<% _.each(slides, function(slide) { %>\
  <a href="<%= slide.embeddable %>">\
    <img title="<%= slide.title %>" data-author="By <%= slide.author %>" alt="<%= slide.description %>"\
      src="<%= slide.embeddable %>" longdesc="<%= slide.slideshow_link %>"/>\
  </a>\
<% }); %>',

      /*
       * height and width must be set and may be done here, but note that doing
       * so will override height/width set in the theme
       */
      options  : { 
        //height: 300,
        //width: 'auto'
      }
    }
  ;

  // NOTE you will need to load a theme, like so
  //Galleria.loadTheme('/javascripts/galleria/themes/simple/e9.simple.js');

  $.fn[api] = function(url, opts) {

    var $this = $(this),
        opts  = $.extend({}, defaults.options, opts),
        theme = opts.theme;

    if (opts.theme) {
      Galleria.loadTheme('/javascripts/galleria/themes/' + opts.theme + '/theme.js');
    }

    delete opts.theme;

    var compiled = _.template(defaults.template);

    $.ajax({ 
      url: url, 
      dataType: 'json', 
      success: function(data, status, xhr) {
        if (data instanceof Array) {
          data = { slides: data }
        }

        $this.html(compiled(data));
        $this.galleria(opts);
      }
    });
  }
});
