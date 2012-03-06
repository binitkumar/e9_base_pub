;(function($) {
  /*
   * The actual function of keyup-submit inputs is to fire the "change" event 
   * at a short delay to allow for form submission on input+keyup events
   * without bombarding the server.
   *
   * The name "keyup-submit" is legacy, as the behavior would more appropriately
   * be called "delayed-keyup-change" or something similar.
   *
   * NOTE scope_select in base.js binds to the keyup_submit event
   */
  $.fn.keyup_submit = function(options) {
    options = options || {};

    _.defaults(options, {
      delay: 400
    });

    return this.each(function(i, el) {
      var 
      $this = $(el), 
      cVal  = $this.val();

      $this
        .bind('input keyup', function(){
          clearTimeout($this.data('timer'));

          $this.data('timer', setTimeout(function(){
            $this.removeData('timer');
            $this.change();
          }, options.delay));
        })
        .bind('blur', function(e){
          clearTimeout($this.data('timer'));
        })
        .bind('change', function(e) {
          var val = $this.val();

          if (cVal != val) {
            $this.trigger('keyup_submit', [val, cVal]);
            cVal = val;
          }
        })
      ;
    });
  }

  $(function() {
    $('input.keyup-submit').keyup_submit();
  });

}(jQuery));
