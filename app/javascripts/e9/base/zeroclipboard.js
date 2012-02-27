;(function($) {
  ZeroClipboard.setMoviePath('/swf/ZeroClipboard.swf');

  $.fn.clipboard = function() {
    function onComplete(cli, text) {
      $.event.trigger('e9:flash', ["Copied to clipboard!", 'notice']);
    }

    return this.each(function(i, el) {
      var $el = $(el), clip;

      clip = new ZeroClipboard.Client();

      clip.setText($el.attr('href'));
      clip.addEventListener('onComplete', onComplete);

      $el
        .append(
          clip.getHTML($el.width(), $el.height())
        )
        .click(function(e) {
          e.preventDefault();
          e.stopPropagation();
        })
      ;
    });
  }

  $(function() {
    var _f;(_f = function() {
      $('a.clipboard:not(:has(embed))').clipboard();
    })();

    $(document).ajaxComplete(_f);
  });

})(jQuery);
