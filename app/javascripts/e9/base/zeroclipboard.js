;(function($) {
  ZeroClipboard.setMoviePath('/swf/ZeroClipboard.swf');

  var 

  // mouseover should cover it, but click for good measure (iPad?)
  init_events = "mouseover click",
  
  init = function() {
    /*
     * filter out links that already contain an embed right away
     */
    $(this).not(':has(embed)').each(function(i, el) {
      el = $(el);

      /* 
       * capture and stop propagation on events which cause
       * initialization.
       */
      el.bind(init_events, function(e) {
        e.preventDefault();
        e.stopPropagation();
      })

      /*
       * Then prepare the clip and append it to the element
       */
      clip = new ZeroClipboard.Client();
      clip.setText(el.attr('href'));
      clip.addEventListener('onComplete', complete);

      el.append(clip.getHTML(el.width(), el.height()));
    });
  },

  complete = function(cli, text) {
    if (window.e9 && window.e9.flash) {
      window.e9.flash.notify.notice("Copied to clipboard!");
    }
  }

  $(function() {
    $('a.clipboard').live(init_events, init);
  });

})(jQuery);
