;jQuery(function($) {
  if ($.browser.msie) {
    $("input[type=radio], input[type=checkbox]").click(function() {
      this.blur();
      this.focus();
    });
  }
});
