;(function($) {

  var

  defaults = {
    event: 'click',

    loadError:      function(e, xhr, status, error) { },
    submitError:    function(e, xhr, status, error) { },
    submitSuccess:  function(e, data, status, xhr)  { },
    submitComplete: function(e, xhr) { 
      $.colorbox.close();
    }
  },

  socialPrep = function($this) {
    options = $this.data('social') || $.socialFormify.options

    // get the popup form
    var $snf = $("#social-networking-form");

    $snf
      .bind("ajax:error",    options.submitError)
      .bind("ajax:success",  options.submitSuccess)
      .bind("ajax:complete", options.submitComplete)
      .ensureTextareaMaxlength()
      .submit(function(e) {
        e.preventDefault();
        $snf.callRemote();
      });
    ;
  },

  socialLoad = function() {
    var $this   = $(this),
        options = $this.data('social') || $.socialFormify.options;

    $.ajax({
      url: options.url,
      type: 'GET',
      dataType: 'html',
      // the server will return forbidden if the content is not user/guest
      // roled and thus not elegible for social feed posting
      error: options.loadError,
      // otherwise it has returned the form, open it in colorbox
      success: function(data, status, xhr) {
        $.fn.colorbox({ 
          html: data,
          scrolling: false,
          onComplete: function() { socialPrep($this) }
        });
      }
    });

    return false;
  };

  $.socialFormify = function(options) {
    if (options.url == undefined) return;
    $.socialFormify.options = $.extend({}, defaults, options);
    socialLoad();
  }

  $.fn.socialFormify = function(options) {
    if (options.url == undefined) return;
    options = $.extend({}, defaults, options);

    $(this)
      .data('social', options)
      .bind(options.event, socialLoad)
    ;
  }

})(jQuery);
